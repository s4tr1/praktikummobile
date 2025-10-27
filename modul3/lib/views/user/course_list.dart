import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/course_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kursus'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (courseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: courseController.courses.length,
          itemBuilder: (context, index) {
            final course = courseController.courses[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(course.title ?? "Kursus"),
                subtitle: Text(course.description ?? ""),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () =>
                    Get.toNamed(AppRoutes.courseDetail, arguments: course.id),
              ),
            );
          },
        );
      }),
    );
  }
}
