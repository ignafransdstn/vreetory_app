import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource(this.firestore);

  Future<void> createUser(UserModel user) async {
    await firestore.collection('users').doc(user.uid).set(
          user.toJson(),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }
}
