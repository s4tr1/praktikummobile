import 'package:flutter/material.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyCourses = [
      {"title": "Basic English", "level": "Beginner"},
      {"title": "Conversational English", "level": "Intermediate"},
      {"title": "Business English", "level": "Advanced"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyCourses.length,
      itemBuilder: (context, index) {
        final course = dummyCourses[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xFF003366)),
            title: Text(course["title"]),
            subtitle: Text(course["level"]),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
