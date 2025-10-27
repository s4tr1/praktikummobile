import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'controllers/course_controller.dart';
import 'controllers/quiz_controller.dart';
import 'data/db_helper.dart';
import 'views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDB(); // initialize sqlite
  // initialize controllers so data can be ready
  Get.put(CourseController());
  Get.put(QuizController());
  runApp(const ConatusApp());
}

class ConatusApp extends StatelessWidget {
  const ConatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Conatus Academy',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashView(),
    );
  }
}
