import 'db_helper.dart';
import '../models/progress_model.dart';

class ProgressDAO {
  final dbHelper = DBHelper.instance;

  Future<int> insertOrUpdateProgress(ProgressModel p) async {
    final db = await dbHelper.database;
    // check existing
    final existing = await db.query('progress',
        where: 'userId = ? AND courseId = ?', whereArgs: [p.userId, p.courseId]);
    if (existing.isNotEmpty) {
      final map = p.toMap();
      // update where userId & courseId
      return await db.update('progress', map,
          where: 'userId = ? AND courseId = ?', whereArgs: [p.userId, p.courseId]);
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
}
