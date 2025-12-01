import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import '../services/translation_service.dart';
import 'course_controller.dart';

class QuizController extends GetxController {
  final QuizService _service = QuizService();
  final TranslationService _translationService = TranslationService();

  var quizzes = <QuizModel>[].obs;
  var currentIndex = 0.obs;
  var selectedIndex = (-1).obs;
  var correctCount = 0.obs;
  var loading = false.obs;
  var translatingQuestion = false.obs;
  var translatingOptions = false.obs;
  var translatedQuestion = ''.obs;
  var translatedOptions = <String>[].obs;
  var currentLanguage = 'en'.obs; // 'en' atau 'id'
  var showTranslated = false.obs;

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

  /// Terjemahkan pertanyaan quiz saat ini
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

  /// Terjemahkan semua pilihan jawaban
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

  /// Translate both question dan options sekaligus
  Future<void> translateAll() async {
    if (quizzes.isEmpty) return;

    await Future.wait([
      translateCurrentQuestion(),
      translateCurrentOptions(),
    ]);
  }

  /// Toggle tampilan translated/original
  void toggleShowTranslated() {
    showTranslated.value = !showTranslated.value;
  }

  /// Dapatkan pertanyaan yang ditampilkan (original atau translated)
  String getDisplayQuestion() {
    if (quizzes.isEmpty) return '';
    if (!showTranslated.value || translatedQuestion.value.isEmpty) {
      return quizzes[currentIndex.value].question;
    }
    return translatedQuestion.value;
  }

  /// Dapatkan pilihan yang ditampilkan (original atau translated)
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

  /// Reset translation saat pindah soal
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
      // finished quiz -> update course progress
      final percent = ((correctCount.value / quizzes.length) * 100).toInt();
      final courseCtrl = Get.find<CourseController>();
      courseCtrl.updateProgress(1, percent);

      Get.dialog(
        AlertDialog(
          title: const Text('Quiz Finished'),
          content: Text('Score: ${correctCount.value}/${quizzes.length}'),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                  Get.offNamed('/home');
                },
                child: const Text('OK'))
          ],
        ),
      );
    }
  }
}
