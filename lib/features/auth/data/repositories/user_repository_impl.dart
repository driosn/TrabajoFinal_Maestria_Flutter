import '../../../../core/database/database_helper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _databaseHelper;

  UserRepositoryImpl(this._databaseHelper);

  @override
  Future<User?> login(String email, String password) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  @override
  Future<List<User>> getUsers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromJson(maps[i]));
  }

  @override
  Future<User> createUser(User user) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('users', UserModel.fromUser(user).toJson());
    return UserModel.fromUser(user, id: id);
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<User> updateUser(User user) async {
    final db = await _databaseHelper.database;
    await db.update(
      'users',
      UserModel.fromUser(user).toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null;
    }

    return User.fromMap(maps.first);
  }
}
