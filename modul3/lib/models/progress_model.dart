class ProgressModel {
  final int? id;
  final int userId;
  final int courseId;
  final double progress; // 0..1
  final int? score;

  ProgressModel({
    this.id,
    required this.userId,
    required this.courseId,
    required this.progress,
    this.score,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> m) => ProgressModel(
    id: m['id'] as int?,
    userId: m['userId'] as int,
    courseId: m['courseId'] as int,
    progress: (m['progress'] as num).toDouble(),
    score: m['score'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'courseId': courseId,
    'progress': progress,
    'score': score,
  };
}
