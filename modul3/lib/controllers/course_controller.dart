import 'package:get/get.dart';
import '../database/course_dao.dart';
import '../models/course_model.dart';

class CourseController extends GetxController {
  final CourseDAO courseDAO = CourseDAO();

  var courses = <CourseModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      final data = await courseDAO.getAllCourses();
      courses.value = data;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load courses: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addCourse(CourseModel course) async {
    try {
      await courseDAO.insertCourse(course);
      await loadCourses();
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add course: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateCourse(CourseModel course) async {
    try {
      await courseDAO.updateCourse(course);
      await loadCourses();
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update course: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      await courseDAO.deleteCourse(id);
      await loadCourses();
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete course: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  CourseModel? getCourseById(int id) {
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }
}
