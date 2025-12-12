class UserEntity {
  final String uid;
  final String email;
  final String role;
  final bool adminRequest;
  final bool? isApproved;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? name;
  final String? phone;

  UserEntity ({
    required this.uid,
    required this.email,
    required this.role,
    required this.adminRequest,
    required this.isApproved,
    required this.createdAt,
    this.approvedAt,
    this.name,
    this.phone,
  });
}