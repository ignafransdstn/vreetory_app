import 'package:vreetory_app/features/authentication/domain/entities/user_entity.dart';

/// Cashier information extracted from UserEntity
/// This is embedded in each transaction to track who processed it
class CashierInfo {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? phone;

  CashierInfo({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
  });

  /// Factory method to create CashierInfo from authenticated UserEntity
  factory CashierInfo.fromUser(UserEntity user) {
    return CashierInfo(
      uid: user.uid,
      email: user.email,
      name: user.name ?? user.email.split('@')[0], // fallback to email prefix
      role: user.role,
      phone: user.phone,
    );
  }

  /// Create a copy with modified fields
  CashierInfo copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? phone,
  }) {
    return CashierInfo(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }
}
