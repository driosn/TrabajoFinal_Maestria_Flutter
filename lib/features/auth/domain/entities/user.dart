class User {
  final int? id;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final int roleId;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.roleId,
    required this.createdAt,
  });
}
