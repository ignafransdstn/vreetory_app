import 'package:vreetory_app/features/authentication/domain/entities/user_request_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestModel extends UserRequestEntity {
  UserRequestModel(
      {required super.uid,
      required super.rid,
      required super.email,
      required super.requestedAt,
      required super.status});

  factory UserRequestModel.fromJson(Map<String, dynamic> json) {
    return UserRequestModel(
        uid: json['uid'],
        rid: json['rid'],
        email: json['email'],
        requestedAt: (json['requestedAt'] as Timestamp).toDate(),
        status: json['status']);
  }

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'rid' : rid,
    'email' : email,
    'requestedAt' : requestedAt,
    'status' : status
  };
}
