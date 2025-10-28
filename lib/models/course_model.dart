class CourseModel {
  int id;
  String title;
  String level;
  int progress;

  CourseModel({
    required this.id,
    required this.title,
    required this.level,
    required this.progress,
  });

  factory CourseModel.fromMap(Map<String, dynamic> m) => CourseModel(
    id: m['id'] as int,
    title: m['title'] as String,
    level: m['level'] as String,
    progress: m['progress'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'level': level,
    'progress': progress,
  };
}
