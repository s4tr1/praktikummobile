import 'package:hive/hive.dart';

part 'course_model.g.dart';

@HiveType(typeId: 1)
class CourseModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String level;

  @HiveField(3)
  int progress;

  @HiveField(4)
  String? description;

  @HiveField(5)
  DateTime? createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.level,
    required this.progress,
    this.description,
    this.createdAt,
  });

  // From Supabase JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      title: json['title'] as String,
      level: json['level'] as String,
      progress: json['progress'] as int? ?? 0,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'progress': progress,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Backward compatibility
  factory CourseModel.fromMap(Map<String, dynamic> m) => CourseModel(
        id: m['id'] as int,
        title: m['title'] as String,
        level: m['level'] as String,
        progress: m['progress'] as int? ?? 0,
        description: m['description'] as String?,
        createdAt:
            m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'level': level,
        'progress': progress,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
      };
}
