import '../models/user_model.dart';
import 'db_helper.dart';

class UserDAO {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> insertUser(UserModel user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(String username, String password) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) return UserModel.fromMap(res.first);
    return null;
  }

  Future<UserModel?> getUserByName(String username) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (res.isNotEmpty) return UserModel.fromMap(res.first);
    return null;
  }

  // ✅ Tambahan opsional untuk kelola user di admin
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final res = await db.query('users');
    return res.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
