import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_request_model.dart';

class UserRequestRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRequestRemoteDataSource(this.firestore);

  Future<void> createUserRequest(UserRequestModel userRequest) async {
    await firestore.collection('usersRequest').doc(userRequest.uid).set(userRequest.toJson());
  }

  Future<UserRequestModel?> getUserRequest(String uid) async {
    final doc = await firestore.collection('usersRequest').doc(uid).get();
    if (doc.exists) {
      return UserRequestModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }
}