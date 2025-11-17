import 'package:hive/hive.dart';

part 'quiz_model.g.dart';

@HiveType(typeId: 2)
class QuizModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  List<String> options;

  @HiveField(3)
  int answerIndex; // 0-based index

  @HiveField(4)
  int? courseId;

  @HiveField(5)
  String? difficulty;

  @HiveField(6)
  DateTime? createdAt;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
    this.courseId,
    this.difficulty,
    this.createdAt,
  });

  // From Supabase JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'].toString(),
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      answerIndex: json['answer_index'] as int,
      courseId: json['course_id'] as int?,
      difficulty: json['difficulty'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer_index': answerIndex,
      'course_id': courseId,
      'difficulty': difficulty,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Backward compatibility
  factory QuizModel.fromMap(Map<String, dynamic> m) {
    final opts = List<String>.from(m['options'] ?? []);
    return QuizModel(
      id: m['id'].toString(),
      question: m['question'] ?? '',
      options: opts,
      answerIndex: m['answer_index'] ?? 0,
      courseId: m['course_id'] as int?,
      difficulty: m['difficulty'] as String?,
      createdAt:
          m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'options': options,
        'answer_index': answerIndex,
        'course_id': courseId,
        'difficulty': difficulty,
        'created_at': createdAt?.toIso8601String(),
      };
}
