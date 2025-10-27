import 'package:get/get.dart';
import '../controllers/progress_controller.dart';
import '../controllers/course_controller.dart';

class DashboardPresenter extends GetxController {
  final ProgressController progressController = Get.find();
  final CourseController courseController = Get.find();

  RxInt completedCourses = 0.obs;
  RxInt totalCourses = 0.obs;
  RxDouble averageScore = 0.0.obs;

  void loadDashboardData() {
    totalCourses.value = courseController.courses.length;
    completedCourses.value = progressController.completedCourses.value;
    averageScore.value = progressController.averageScore.value;
  }

  void refreshData() {
    courseController.loadCourses();
    loadDashboardData();
  }
}
