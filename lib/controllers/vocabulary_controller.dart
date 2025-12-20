import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vocabulary_model.dart';
import '../services/vocabulary_service.dart';
import '../services/hive_service.dart';

class VocabularyController extends GetxController {
  final VocabularyService _service = VocabularyService.instance;
  final HiveService _hiveService = HiveService();

  // Observable states
  final allWords = <VocabularyWord>[].obs;
  final filteredWords = <VocabularyWord>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters
  final selectedLevel = 'all'.obs;
  final selectedCategory = 'all'.obs;
  final searchQuery = ''.obs;
  final showOnlyUnlearned = false.obs;

  // Progress
  final progress = Rxn<VocabularyProgress>();

  // Quiz states
  final quizQuestions = <VocabularyQuizQuestion>[].obs;
  final currentQuizIndex = 0.obs;
  final selectedQuizOption = (-1).obs;
  final quizScore = 0.obs;
  final isQuizMode = false.obs;

  // Flashcard states
  final currentFlashcard = Rxn<VocabularyWord>();
  final showFlashcardAnswer = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVocabulary();
  }

  // ========== LOAD DATA ==========

  Future<void> loadVocabulary() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load from JSON
      final words = await _service.loadVocabulary();
      
      // Load progress from Hive cache
      final cachedWords = _hiveService.getCachedVocabulary();
      if (cachedWords.isNotEmpty) {
        // Merge: use cached progress, keep JSON data
        for (var word in words) {
          final cached = cachedWords.firstWhereOrNull((w) => w.id == word.id);
          if (cached != null) {
            word.isLearned = cached.isLearned;
            word.learnedAt = cached.learnedAt;
            word.reviewCount = cached.reviewCount;
            word.lastReviewedAt = cached.lastReviewedAt;
          }
        }
      }

      allWords.assignAll(words);
      applyFilters();
      updateProgress();

      print('✅ Loaded ${words.length} vocabulary words');
    } catch (e) {
      errorMessage.value = 'Failed to load vocabulary: $e';
      print('❌ Error loading vocabulary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========== FILTERS ==========

  void applyFilters() {
    List<VocabularyWord> filtered = List.from(allWords);

    // Level filter
    if (selectedLevel.value != 'all') {
      filtered = _service.filterByLevel(filtered, selectedLevel.value);
    }

    // Category filter
    if (selectedCategory.value != 'all') {
      filtered = _service.filterByCategory(filtered, selectedCategory.value);
    }

    // Search query
    if (searchQuery.value.isNotEmpty) {
      filtered = _service.searchWords(filtered, searchQuery.value);
    }

    // Show only unlearned
    if (showOnlyUnlearned.value) {
      filtered = filtered.where((w) => !w.isLearned).toList();
    }

    filteredWords.assignAll(filtered);
  }

  void setLevelFilter(String level) {
    selectedLevel.value = level;
    applyFilters();
  }

  void setCategoryFilter(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void toggleShowUnlearned() {
    showOnlyUnlearned.value = !showOnlyUnlearned.value;
    applyFilters();
  }

  void clearFilters() {
    selectedLevel.value = 'all';
    selectedCategory.value = 'all';
    searchQuery.value = '';
    showOnlyUnlearned.value = false;
    applyFilters();
  }

  // ========== WORD ACTIONS ==========

  Future<void> markWordAsLearned(VocabularyWord word) async {
    word.markAsLearned();
    await _saveToCache();
    updateProgress();
    applyFilters();

    Get.snackbar(
      '✅ Word Learned!',
      '"${word.word}" has been added to your learned words',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> reviewWord(VocabularyWord word) async {
    word.review();
    await _saveToCache();
    updateProgress();

    Get.snackbar(
      '🔄 Word Reviewed',
      'Review count: ${word.reviewCount}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // ========== QUIZ MODE ==========

  void startQuiz({String? level, String? category, int questionCount = 10}) {
    try {
      quizQuestions.assignAll(
        _service.generateQuiz(
          allWords: allWords,
          questionCount: questionCount,
          level: level,
          category: category,
        ),
      );

      if (quizQuestions.isEmpty) {
        Get.snackbar(
          'Error',
          'Not enough words to generate quiz',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      currentQuizIndex.value = 0;
      selectedQuizOption.value = -1;
      quizScore.value = 0;
      isQuizMode.value = true;

      Get.toNamed('/vocabulary/quiz');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void selectQuizOption(int index) {
    selectedQuizOption.value = index;
  }

  void submitQuizAnswer() {
    if (selectedQuizOption.value < 0) return;

    final question = quizQuestions[currentQuizIndex.value];
    if (selectedQuizOption.value == question.correctIndex) {
      quizScore.value++;
    }

    // Auto mark as learned if answered correctly
    if (selectedQuizOption.value == question.correctIndex) {
      markWordAsLearned(question.word);
    }
  }

  void nextQuizQuestion() {
    submitQuizAnswer();
    selectedQuizOption.value = -1;

    if (currentQuizIndex.value < quizQuestions.length - 1) {
      currentQuizIndex.value++;
    } else {
      finishQuiz();
    }
  }

  void finishQuiz() {
    isQuizMode.value = false;
    final percentage = ((quizScore.value / quizQuestions.length) * 100).toInt();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              percentage >= 80 ? Icons.emoji_events : Icons.thumb_up,
              color: percentage >= 80 ? Colors.amber : Colors.blue,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Quiz Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${quizScore.value}/${quizQuestions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $percentage%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80 ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Return to vocabulary list
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              startQuiz(
                level: selectedLevel.value != 'all' ? selectedLevel.value : null,
                category: selectedCategory.value != 'all' ? selectedCategory.value : null,
              );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ========== FLASHCARD MODE ==========

  void startFlashcard() {
    final word = _service.getRandomWord(allWords, onlyUnlearned: showOnlyUnlearned.value);
    if (word == null) {
      Get.snackbar(
        'No Words',
        'All words have been learned!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentFlashcard.value = word;
    showFlashcardAnswer.value = false;
  }

  void flipFlashcard() {
    showFlashcardAnswer.value = !showFlashcardAnswer.value;
  }

  void nextFlashcard({bool markAsLearned = false}) {
    if (markAsLearned && currentFlashcard.value != null) {
      this.markWordAsLearned(currentFlashcard.value!);
    }

    final word = _service.getRandomWord(
      allWords,
      onlyUnlearned: showOnlyUnlearned.value,
    );

    if (word == null) {
      Get.snackbar(
        '🎉 Congratulations!',
        'You have learned all available words!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      currentFlashcard.value = null;
      return;
    }

    currentFlashcard.value = word;
    showFlashcardAnswer.value = false;
  }

  // ========== PROGRESS ==========

  void updateProgress() {
    progress.value = _service.calculateProgress(allWords);
  }

  // ========== CACHE ==========

  Future<void> _saveToCache() async {
    try {
      await _hiveService.saveVocabulary(allWords);
    } catch (e) {
      print('Error saving vocabulary to cache: $e');
    }
  }

  // ========== RESET ==========

  Future<void> resetAllProgress() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('Are you sure you want to reset all vocabulary progress?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              for (var word in allWords) {
                word.isLearned = false;
                word.learnedAt = null;
                word.reviewCount = 0;
                word.lastReviewedAt = null;
              }
              await _saveToCache();
              updateProgress();
              applyFilters();

              Get.snackbar(
                'Progress Reset',
                'All vocabulary progress has been reset',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
