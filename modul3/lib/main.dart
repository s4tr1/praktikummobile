import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/course_controller.dart';
import 'controllers/progress_controller.dart';
import 'routes/app_routes.dart';
import 'utils/app_colors.dart';

void main() {
  // Pastikan binding GetX siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inject semua controller global
  Get.put(AuthController(), permanent: true);
  Get.put(CourseController(), permanent: true);
  Get.put(ProgressController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.dashboard, // mulai dari dashboard
      getPages: AppRoutes.routes, // daftar route
    );
  }
}
