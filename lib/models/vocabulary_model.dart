import 'package:hive/hive.dart';

part 'vocabulary_model.g.dart';

@HiveType(typeId: 4)
class VocabularyWord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String word;

  @HiveField(2)
  String partOfSpeech; // noun, verb, adjective, etc.

  @HiveField(3)
  String pronunciation;

  @HiveField(4)
  String definition;

  @HiveField(5)
  String indonesianMeaning;

  @HiveField(6)
  List<String> examples;

  @HiveField(7)
  List<String> synonyms;

  @HiveField(8)
  String level; // beginner, intermediate, advanced

  @HiveField(9)
  String category; // daily, business, academic, etc.

  @HiveField(10)
  bool isLearned;

  @HiveField(11)
  DateTime? learnedAt;

  @HiveField(12)
  int reviewCount;

  @HiveField(13)
  DateTime? lastReviewedAt;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.definition,
    required this.indonesianMeaning,
    required this.examples,
    this.synonyms = const [],
    this.level = 'beginner',
    this.category = 'general',
    this.isLearned = false,
    this.learnedAt,
    this.reviewCount = 0,
    this.lastReviewedAt,
  });

  // From JSON
  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String,
      pronunciation: json['pronunciation'] as String,
      definition: json['definition'] as String,
      indonesianMeaning: json['indonesian_meaning'] as String,
      examples: List<String>.from(json['examples'] ?? []),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      level: json['level'] as String? ?? 'beginner',
      category: json['category'] as String? ?? 'general',
      isLearned: json['is_learned'] as bool? ?? false,
      learnedAt: json['learned_at'] != null 
          ? DateTime.parse(json['learned_at']) 
          : null,
      reviewCount: json['review_count'] as int? ?? 0,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.parse(json['last_reviewed_at'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'part_of_speech': partOfSpeech,
      'pronunciation': pronunciation,
      'definition': definition,
      'indonesian_meaning': indonesianMeaning,
      'examples': examples,
      'synonyms': synonyms,
      'level': level,
      'category': category,
      'is_learned': isLearned,
      'learned_at': learnedAt?.toIso8601String(),
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
    };
  }

  // Mark as learned
  void markAsLearned() {
    isLearned = true;
    learnedAt = DateTime.now();
    save();
  }

  // Review word
  void review() {
    reviewCount++;
    lastReviewedAt = DateTime.now();
    save();
  }

  // Calculate mastery level (0-100)
  int get masteryLevel {
    if (!isLearned) return 0;
    
    // Simple algorithm: more reviews = higher mastery
    int score = 20; // Base score for learning
    score += (reviewCount * 10).clamp(0, 80); // Max 80 from reviews
    
    return score.clamp(0, 100);
  }

  // Check if needs review (spaced repetition)
  bool get needsReview {
    if (!isLearned) return false;
    if (lastReviewedAt == null) return true;
    
    final daysSinceReview = DateTime.now().difference(lastReviewedAt!).inDays;
    
    // Simple spaced repetition
    if (reviewCount == 0) return daysSinceReview >= 1; // Review after 1 day
    if (reviewCount == 1) return daysSinceReview >= 3; // Review after 3 days
    if (reviewCount == 2) return daysSinceReview >= 7; // Review after 1 week
    return daysSinceReview >= 30; // Review after 1 month
  }
}

// Quiz Question Model
class VocabularyQuizQuestion {
  final VocabularyWord word;
  final List<String> options; // 4 options including correct answer
  final int correctIndex;
  final String questionType; // 'meaning', 'example', 'synonym'

  VocabularyQuizQuestion({
    required this.word,
    required this.options,
    required this.correctIndex,
    this.questionType = 'meaning',
  });

  String get question {
    switch (questionType) {
      case 'meaning':
        return 'What is the meaning of "${word.word}"?';
      case 'example':
        return 'Which sentence uses "${word.word}" correctly?';
      case 'synonym':
        return 'What is a synonym of "${word.word}"?';
      default:
        return 'What is the meaning of "${word.word}"?';
    }
  }
}

// Progress Stats
class VocabularyProgress {
  final int totalWords;
  final int learnedWords;
  final int masteredWords; // mastery >= 80
  final int needsReviewCount;
  final Map<String, int> categoryProgress;
  final Map<String, int> levelProgress;

  VocabularyProgress({
    required this.totalWords,
    required this.learnedWords,
    required this.masteredWords,
    required this.needsReviewCount,
    required this.categoryProgress,
    required this.levelProgress,
  });

  double get overallProgress {
    if (totalWords == 0) return 0;
    return (learnedWords / totalWords) * 100;
  }

  double get masteryProgress {
    if (totalWords == 0) return 0;
    return (masteredWords / totalWords) * 100;
  }
}
