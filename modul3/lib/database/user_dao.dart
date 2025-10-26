import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import 'db_helper.dart';

class UserDAO {
  final DBHelper _dbHelper = DBHelper();

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
}
