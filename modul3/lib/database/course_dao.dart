import 'db_helper.dart';
import '../models/course_model.dart';

class CourseDAO {
  final dbHelper = DBHelper.instance;

  Future<int> insertCourse(CourseModel c) async {
    final db = await dbHelper.database;
    return await db.insert('courses', c.toMap());
  }

  Future<List<CourseModel>> getAllCourses() async {
    final db = await dbHelper.database;
    final res = await db.query('courses');
    return res.map((m) => CourseModel.fromMap(m)).toList();
  }

  Future<int> updateCourse(CourseModel c) async {
    final db = await dbHelper.database;
    return await db.update('courses', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCourse(int id) async {
    final db = await dbHelper.database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }
}
