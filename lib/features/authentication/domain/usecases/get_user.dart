import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<UserEntity?> call(String uid) async {
    return await repository.getUser(uid);
  }
}