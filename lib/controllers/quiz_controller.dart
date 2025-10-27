import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import 'course_controller.dart';

class QuizController extends GetxController {
  final QuizService _service = QuizService();
  var quizzes = <QuizModel>[].obs;
  var currentIndex = 0.obs;
  var selectedIndex = (-1).obs;
  var correctCount = 0.obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadQuizzes({String courseKey = 'basic_grammar'}) async {
    loading.value = true;
    try {
      final list = await _service.fetchQuizzes(course: courseKey);
      quizzes.assignAll(list);
      currentIndex.value = 0;
      selectedIndex.value = -1;
      correctCount.value = 0;
    } finally {
      loading.value = false;
    }
  }

  void selectOption(int idx) {
    selectedIndex.value = idx;
  }

  void nextQuestion() {
    final q = quizzes[currentIndex.value];
    if (selectedIndex.value == q.answerIndex) {
      correctCount.value++;
    }
    selectedIndex.value = -1;
    if (currentIndex.value < quizzes.length - 1) {
      currentIndex.value++;
    } else {
      // finished quiz -> update course progress sample (simple)
      // assume percentage = correctCount/quizzes.length * 100
      final percent = ((correctCount.value / quizzes.length) * 100).toInt();
      final courseCtrl = Get.find<CourseController>();
      // update progress for course id 1 (sample)
      courseCtrl.updateProgress(1, percent);
      // show dialog
      Get.dialog(AlertDialog(
        title: const Text('Quiz Finished'),
        content: Text('Score: ${correctCount.value}/${quizzes.length}'),
        actions: [
          TextButton(onPressed: () {
            Get.back(); // close dialog
            Get.offNamed('/home');
          }, child: const Text('OK'))
        ],
      ));
    }
  }
}
