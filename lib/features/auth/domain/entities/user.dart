class User {
  final int? id;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final String role;
  final bool isActive;

  User({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
  });

  User copyWith({
    int? id,
    String? name,
    String? lastName,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      isActive: map['isActive'] == 1,
    );
  }
}
