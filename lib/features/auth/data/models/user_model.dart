import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    int? id,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int roleId,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          lastName: lastName,
          email: email,
          password: password,
          roleId: roleId,
          createdAt: createdAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      roleId: json['roleId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory UserModel.fromUser(User user, {int? id}) {
    return UserModel(
      id: id ?? user.id,
      name: user.name,
      lastName: user.lastName,
      email: user.email,
      password: user.password,
      roleId: user.roleId,
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,
      'roleId': roleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
