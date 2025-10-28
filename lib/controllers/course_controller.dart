import 'package:get/get.dart';
import '../data/db_helper.dart';
import '../models/course_model.dart';

class CourseController extends GetxController {
  var courses = <CourseModel>[].obs;
  final db = DBHelper.instance;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final d = await db.database;
    final rows = await d.query('courses');
    courses.value = rows.map((r) => CourseModel.fromMap(r)).toList();
  }

  Future<void> updateProgress(int courseId, int progress) async {
    final d = await db.database;
    await d.update('courses', {'progress': progress}, where: 'id = ?', whereArgs: [courseId]);
    await loadCourses();
  }
}
