import '../../domain/entities/cashier_info.dart';

/// Data model for CashierInfo with Firestore serialization
class CashierInfoModel extends CashierInfo {
  CashierInfoModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.phone,
  });

  /// Create model from entity
  factory CashierInfoModel.fromEntity(CashierInfo entity) {
    return CashierInfoModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      phone: entity.phone,
    );
  }

  /// Create model from Firestore JSON
  factory CashierInfoModel.fromJson(Map<String, dynamic> json) {
    return CashierInfoModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
    };
  }
}
