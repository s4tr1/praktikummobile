class CourseModel {
  final int? id;
  final String title;
  final String description;
  final String level;
  final String imagePath;

  CourseModel({
    this.id,
    required this.title,
    this.description = '',
    this.level = 'Beginner',
    this.imagePath = '',
  });

  factory CourseModel.fromMap(Map<String, dynamic> m) => CourseModel(
    id: m['id'] as int?,
    title: m['title'] as String,
    description: m['description'] as String? ?? '',
    level: m['level'] as String? ?? 'Beginner',
    imagePath: m['imagePath'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'level': level,
    'imagePath': imagePath,
  };
}
