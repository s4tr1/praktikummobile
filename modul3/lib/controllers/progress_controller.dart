import 'package:get/get.dart';
import '../database/progress_dao.dart';

class ProgressController extends GetxController {
  final ProgressDAO progressDAO = ProgressDAO();

  var totalCourses = 0.obs;
  var completedCourses = 0.obs;
  var totalQuizzes = 0.obs;
  var averageScore = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    totalCourses.value = await progressDAO.getTotalCourses();
    completedCourses.value = await progressDAO.getCompletedCourses();
    totalQuizzes.value = await progressDAO.getTotalQuizzesTaken();
    averageScore.value = await progressDAO.getAverageScore();
  }
}
