import 'package:flutter/material.dart';
import '../../database/course_dao.dart';
import '../../models/course_model.dart';
import '../../utils/app_colors.dart';

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  State<ManageCoursesPage> createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> {
  final CourseDAO _dao = CourseDAO();
  List<CourseModel> courses = [];

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _levelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final data = await _dao.getAllCourses();
    setState(() => courses = data);
  }

  Future<void> _addCourse() async {
    final newCourse = CourseModel(
      title: _titleController.text,
      description: _descController.text,
      level: _levelController.text,
    );
    await _dao.insertCourse(newCourse);
    _loadCourses();
    _titleController.clear();
    _descController.clear();
    _levelController.clear();
  }

  Future<void> _deleteCourse(int id) async {
    await _dao.deleteCourse(id);
    _loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kursus'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Kursus'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: _levelController,
              decoration: const InputDecoration(labelText: 'Level (A1, A2, B1...)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCourse,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Tambah Kursus"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final c = courses[index];
                  return Card(
                    child: ListTile(
                      title: Text(c.title),
                      subtitle: Text('Level: ${c.level}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCourse(c.id!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
