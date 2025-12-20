import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/vocabulary_model.dart';

class VocabularyService {
  static final VocabularyService instance = VocabularyService._();
  VocabularyService._();

  // Load vocabulary from JSON file
  Future<List<VocabularyWord>> loadVocabulary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/vocabulary_words.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> wordsJson = jsonData['words'] ?? [];
      
      return wordsJson
          .map((json) => VocabularyWord.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading vocabulary: $e');
      return [];
    }
  }

  // Filter by level
  List<VocabularyWord> filterByLevel(List<VocabularyWord> words, String level) {
    return words.where((word) => word.level == level).toList();
  }

  // Filter by category
  List<VocabularyWord> filterByCategory(List<VocabularyWord> words, String category) {
    return words.where((word) => word.category == category).toList();
  }

  // Get learned words
  List<VocabularyWord> getLearnedWords(List<VocabularyWord> words) {
    return words.where((word) => word.isLearned).toList();
  }

  // Get words that need review
  List<VocabularyWord> getWordsNeedingReview(List<VocabularyWord> words) {
    return words.where((word) => word.needsReview).toList();
  }

  // Search words
  List<VocabularyWord> searchWords(List<VocabularyWord> words, String query) {
    final lowerQuery = query.toLowerCase();
    return words.where((word) => 
      word.word.toLowerCase().contains(lowerQuery) ||
      word.definition.toLowerCase().contains(lowerQuery) ||
      word.indonesianMeaning.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Generate quiz questions
  List<VocabularyQuizQuestion> generateQuiz({
    required List<VocabularyWord> allWords,
    int questionCount = 10,
    String? level,
    String? category,
  }) {
    // Filter words
    List<VocabularyWord> filteredWords = allWords;
    if (level != null) {
      filteredWords = filterByLevel(filteredWords, level);
    }
    if (category != null) {
      filteredWords = filterByCategory(filteredWords, category);
    }

    if (filteredWords.length < 4) {
      throw Exception('Not enough words to generate quiz');
    }

    final questions = <VocabularyQuizQuestion>[];
    final usedWords = <String>{};
    filteredWords.shuffle();

    for (int i = 0; i < questionCount && i < filteredWords.length; i++) {
      final word = filteredWords[i];
      if (usedWords.contains(word.id)) continue;
      usedWords.add(word.id);

      // Generate options
      final options = <String>[word.indonesianMeaning];
      final otherWords = filteredWords
          .where((w) => w.id != word.id && !options.contains(w.indonesianMeaning))
          .toList();
      otherWords.shuffle();

      for (int j = 0; j < 3 && j < otherWords.length; j++) {
        options.add(otherWords[j].indonesianMeaning);
      }

      if (options.length < 4) continue;

      options.shuffle();
      final correctIndex = options.indexOf(word.indonesianMeaning);

      questions.add(VocabularyQuizQuestion(
        word: word,
        options: options,
        correctIndex: correctIndex,
        questionType: 'meaning',
      ));
    }

    return questions;
  }

  // Calculate progress
  VocabularyProgress calculateProgress(List<VocabularyWord> words) {
    final totalWords = words.length;
    final learnedWords = words.where((w) => w.isLearned).length;
    final masteredWords = words.where((w) => w.masteryLevel >= 80).length;
    final needsReview = words.where((w) => w.needsReview).length;

    // Category progress
    final categoryProgress = <String, int>{};
    for (var word in words) {
      if (word.isLearned) {
        categoryProgress[word.category] = (categoryProgress[word.category] ?? 0) + 1;
      }
    }

    // Level progress
    final levelProgress = <String, int>{};
    for (var word in words) {
      if (word.isLearned) {
        levelProgress[word.level] = (levelProgress[word.level] ?? 0) + 1;
      }
    }

    return VocabularyProgress(
      totalWords: totalWords,
      learnedWords: learnedWords,
      masteredWords: masteredWords,
      needsReviewCount: needsReview,
      categoryProgress: categoryProgress,
      levelProgress: levelProgress,
    );
  }

  // Get random word for flashcard
  VocabularyWord? getRandomWord(List<VocabularyWord> words, {bool onlyUnlearned = false}) {
    List<VocabularyWord> filtered = onlyUnlearned 
        ? words.where((w) => !w.isLearned).toList()
        : words;
    
    if (filtered.isEmpty) return null;
    
    filtered.shuffle();
    return filtered.first;
  }
}
