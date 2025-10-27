import 'package:get/get.dart';

class ProgressController extends GetxController {
  var completedCourses = 0.obs;
  var totalCourses = 0.obs;
  var averageScore = 0.0.obs;

  void updateProgress({int? completed, int? total, double? score}) {
    if (completed != null) completedCourses.value = completed;
    if (total != null) totalCourses.value = total;
    if (score != null) averageScore.value = score;
  }
}
