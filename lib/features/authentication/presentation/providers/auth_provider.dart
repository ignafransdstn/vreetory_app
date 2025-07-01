import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vreetory_app/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:vreetory_app/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:vreetory_app/features/authentication/domain/entities/user_entity.dart';
import 'package:vreetory_app/features/authentication/domain/usecases/create_user.dart';
import '../pages/admin_home_page.dart';
import '../pages/user_home_page.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn(BuildContext context, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final role = doc['role'];

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          } else if (role == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserHomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown role')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found in Firestore')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    }
  }

  Future<void> createUser(UserEntity userEntity) async {
    final firestore = FirebaseFirestore.instance;
    final remote = UserRemoteDataSource(firestore);
    final repository = UserRepositoryImpl(remote);
    final usecase = CreateUser(repository);
    await usecase(userEntity);
    // Optionally, update the state if needed to notify listeners
    try {
      await usecase(userEntity);
      state = state.copyWith(status: AuthStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message ?? e.toString(),);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
