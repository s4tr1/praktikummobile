import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../controllers/progress_controller.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseId = Get.arguments;
    final progressController = Get.find<ProgressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulasikan penyelesaian kursus
            progressController.completedCourses.value += 1;
            progressController.updateProgress();

            Get.snackbar("Selesai!", "Kuis berhasil diselesaikan.");
            Future.delayed(const Duration(seconds: 1), () {
              Get.offNamed(AppRoutes.certificate);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Selesaikan Kursus & Dapatkan Sertifikat"),
        ),
      ),
    );
  }
}
