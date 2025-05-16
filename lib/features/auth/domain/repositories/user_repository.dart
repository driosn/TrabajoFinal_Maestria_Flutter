import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> login(String email, String password);
  Future<List<User>> getUsers();
  Future<User> createUser(User user);
  Future<void> deleteUser(int id);
  Future<User> updateUser(User user);
}
