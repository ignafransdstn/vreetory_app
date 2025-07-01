import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createUser(UserEntity user) async {

    final  isEmailTaken = await remoteDataSource.isEmailRegistered(user.email);
    if (isEmailTaken) {
      throw Exception('Email is already registered');
    }
    final model = UserModel(
      uid: user.uid,
      email: user.email,
      role: user.role,
      adminRequest: user.adminRequest,
      isApproved: user.isApproved,
      createdAt: user.createdAt,
    );
    await remoteDataSource.createUser(model);
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final model = await remoteDataSource.getUser(uid);
    return model;
  }
}
