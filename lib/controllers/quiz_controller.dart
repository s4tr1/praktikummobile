import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import '../services/translation_service.dart';
import '../services/notification_service.dart';
import 'course_controller.dart';

class QuizController extends GetxController {
  final QuizService _service = QuizService();
  final TranslationService _translationService = TranslationService();
  final NotificationService _notificationService = NotificationService.instance;

  var quizzes = <QuizModel>[].obs;
  var currentIndex = 0.obs;
  var selectedIndex = (-1).obs;
  var correctCount = 0.obs;
  var loading = false.obs;
  var translatingQuestion = false.obs;
  var translatingOptions = false.obs;
  var translatedQuestion = ''.obs;
  var translatedOptions = <String>[].obs;
  var currentLanguage = 'en'.obs;
  var showTranslated = false.obs;
  var courseName = 'Basic Grammar'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadQuizzes({String courseKey = 'basic_grammar'}) async {
    loading.value = true;
    courseName.value = courseKey
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    try {
      final list = await _service.fetchQuizzes(course: courseKey);
      quizzes.assignAll(list);
      currentIndex.value = 0;
      selectedIndex.value = -1;
      correctCount.value = 0;
      currentLanguage.value = 'en';
      translatedQuestion.value = '';
      translatedOptions.clear();
      showTranslated.value = false;
    } finally {
      loading.value = false;
    }
  }

  void selectOption(int idx) {
    selectedIndex.value = idx;
  }

  Future<void> translateCurrentQuestion() async {
    if (quizzes.isEmpty) return;

    final q = quizzes[currentIndex.value];
    final targetLanguage = currentLanguage.value == 'en' ? 'id' : 'en';

    translatingQuestion.value = true;
    try {
      final translated = await _translationService.translate(
        text: q.question,
        targetLanguage: targetLanguage,
      );
      translatedQuestion.value = translated;
      currentLanguage.value = targetLanguage;
      showTranslated.value = true;
    } catch (e) {
      Get.snackbar(
        'Translation Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      translatingQuestion.value = false;
    }
  }

  Future<void> translateCurrentOptions() async {
    if (quizzes.isEmpty) return;

    final q = quizzes[currentIndex.value];
    final targetLanguage = currentLanguage.value == 'en' ? 'id' : 'en';

    translatingOptions.value = true;
    try {
      final translated = await _translationService.translateMultiple(
        texts: q.options,
        targetLanguage: targetLanguage,
      );
      translatedOptions.assignAll(translated);
    } catch (e) {
      Get.snackbar(
        'Translation Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      translatingOptions.value = false;
    }
  }

  Future<void> translateAll() async {
    if (quizzes.isEmpty) return;

    await Future.wait([
      translateCurrentQuestion(),
      translateCurrentOptions(),
    ]);
  }

  void toggleShowTranslated() {
    showTranslated.value = !showTranslated.value;
  }

  String getDisplayQuestion() {
    if (quizzes.isEmpty) return '';
    if (!showTranslated.value || translatedQuestion.value.isEmpty) {
      return quizzes[currentIndex.value].question;
    }
    return translatedQuestion.value;
  }

  String getDisplayOption(int index) {
    if (quizzes.isEmpty) return '';
    final q = quizzes[currentIndex.value];

    if (!showTranslated.value ||
        translatedOptions.isEmpty ||
        index >= translatedOptions.length) {
      return q.options[index];
    }
    return translatedOptions[index];
  }

  void _resetTranslation() {
    translatedQuestion.value = '';
    translatedOptions.clear();
    showTranslated.value = false;
    currentLanguage.value = 'en';
  }

  void nextQuestion() {
    final q = quizzes[currentIndex.value];
    if (selectedIndex.value == q.answerIndex) {
      correctCount.value++;
    }
    selectedIndex.value = -1;
    _resetTranslation();

    if (currentIndex.value < quizzes.length - 1) {
      currentIndex.value++;
    } else {
      // ✅ Quiz finished - show notification
      _showQuizCompletionDialog();
    }
  }

  void _showQuizCompletionDialog() async {
    final percent = ((correctCount.value / quizzes.length) * 100).toInt();
    final courseCtrl = Get.find<CourseController>();
    courseCtrl.updateProgress(1, percent);

    // ✅ Send quiz completion notification
    await _notificationService.showQuizCompletionNotification(
      score: correctCount.value,
      total: quizzes.length,
      courseName: courseName.value,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              percent >= 80
                  ? Icons.emoji_events
                  : percent >= 60
                  ? Icons.thumb_up
                  : Icons.emoji_emotions,
              color: percent >= 80
                  ? Colors.amber
                  : percent >= 60
                  ? Colors.blue
                  : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Quiz Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${correctCount.value}/${quizzes.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF087E8B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor Anda: $percent%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 80
                    ? Colors.green
                    : percent >= 60
                    ? Colors.blue
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              percent >= 80
                  ? '🎉 Luar biasa! Kerja yang sangat baik!'
                  : percent >= 60
                  ? '👏 Bagus! Terus tingkatkan!'
                  : '💪 Jangan menyerah! Coba lagi!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offNamed('/home');
            },
            child: const Text('Kembali ke Home'),
          ),
        ],
      ),
    );
  }
}