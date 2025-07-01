class UserEntity {
  final String uid;
  final String email;
  final String role;
  final bool adminRequest;
  final bool? isApproved;
  final DateTime createdAt;

  UserEntity ({
    required this.uid,
    required this.email,
    required this.role,
    required this.adminRequest,
    required this.isApproved,
    required this.createdAt
  });
}