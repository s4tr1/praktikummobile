import 'db_helper.dart';
import '../models/progress_model.dart';
import 'package:sqflite/sqflite.dart';

class ProgressDAO {
  final dbHelper = DBHelper.instance;

  Future<int> insertOrUpdateProgress(ProgressModel p) async {
    final db = await dbHelper.database;
    final existing = await db.query(
      'progress',
      where: 'userId = ? AND courseId = ?',
      whereArgs: [p.userId, p.courseId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'progress',
        p.toMap(),
        where: 'userId = ? AND courseId = ?',
        whereArgs: [p.userId, p.courseId],
      );
    } else {
      return await db.insert('progress', p.toMap());
    }
  }

  Future<List<ProgressModel>> getProgressByUser(int userId) async {
    final db = await dbHelper.database;
    final res = await db.query('progress', where: 'userId = ?', whereArgs: [userId]);
    return res.map((m) => ProgressModel.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllProgressRaw() async {
    final db = await dbHelper.database;
    return await db.query('progress');
  }

  // === Fungsi tambahan untuk dashboard / laporan ===
  Future<int> getTotalCourses() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM courses');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedCourses() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS completed FROM courses WHERE completed = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalQuizzesTaken() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM quizzes_taken');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getAverageScore() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT AVG(score) AS avg_score FROM quizzes_taken');
    return (result.first['avg_score'] as double?) ?? 0.0;
  }
}
