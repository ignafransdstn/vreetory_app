class UserRequestEntity {
  final String uid;
  final String rid;
  final String email;
  final DateTime requestedAt;
  final bool status;

  UserRequestEntity ({
    required this.uid,
    required this.rid,
    required this.email,
    required this.requestedAt,
    required this.status
  });
}