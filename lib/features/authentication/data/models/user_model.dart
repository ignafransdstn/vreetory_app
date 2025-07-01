import 'package:vreetory_app/features/authentication/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.adminRequest,
    required super.isApproved,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      role: json['role'],
      adminRequest: json['admin_request'],
      isApproved: json['is_approved'] as bool?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid' : uid,
    'email' : email,
    'role' : role,
    'admin_request' : adminRequest,
    'is_approved' : isApproved,
    'created_at' : createdAt
  };
}
