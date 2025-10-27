import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/course_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseId = Get.arguments as int?;
    final courseController = Get.find<CourseController>();
    final course = courseController.getCourseById(courseId ?? 0);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kursus Tidak Ditemukan')),
        body: const Center(child: Text('Data kursus tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title ?? "Kursus"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description ?? "",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () =>
                  Get.toNamed(AppRoutes.quiz, arguments: course.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Mulai Kelas'),
            ),
          ],
        ),
      ),
    );
  }
}
