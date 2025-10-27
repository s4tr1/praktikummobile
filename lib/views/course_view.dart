import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';
import '../controllers/quiz_controller.dart';
import '../routes/app_routes.dart';

class CourseView extends StatelessWidget {
  const CourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments as Map<String, dynamic>? ?? {};
    final course = CourseModel.fromMap(arg);
    final quizCtrl = Get.find<QuizController>();

    return Scaffold(
      appBar: AppBar(title: Text(course.title), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF087E8B), Color(0xFF0E1B50)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // tabs simplified
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Overview', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Materials'),
                          Text('Quizzes'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(title: const Text('Lesson 1'), trailing: const Text('0/2')),
                            ListTile(title: const Text('Lesson 2'), trailing: const Text('0/3')),
                            ListTile(title: const Text('Lesson 3'), trailing: const Text('0/3')),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: () async {
                                await quizCtrl.loadQuizzes(courseKey: 'basic_grammar');
                                Get.toNamed(AppRoutes.quiz);
                              },
                              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                              child: const Text('Enroll'),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
