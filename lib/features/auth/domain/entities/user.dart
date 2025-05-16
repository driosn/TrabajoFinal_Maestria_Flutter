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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      roleId: map['roleId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
