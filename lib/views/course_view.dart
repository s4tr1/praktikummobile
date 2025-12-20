import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';
import '../controllers/quiz_controller_dio.dart'; // ✅ HANYA DIO
import '../routes/app_routes.dart';

class CourseView extends StatelessWidget {
  const CourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments as Map<String, dynamic>? ?? {};
    final course = CourseModel.fromMap(arg);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF087E8B), Color(0xFF0E1B50)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // tabs simplified
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Overview',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Materials'),
                          Text('Quizzes'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              title: const Text('Lesson 1'),
                              trailing: const Text('0/2'),
                            ),
                            ListTile(
                              title: const Text('Lesson 2'),
                              trailing: const Text('0/3'),
                            ),
                            ListTile(
                              title: const Text('Lesson 3'),
                              trailing: const Text('0/3'),
                            ),
                            const SizedBox(height: 18),

                            // Section title
                            const Text(
                              'Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ✅ HANYA 1 QUIZ CARD (MENGGUNAKAN DIO)
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  // Initialize DIO controller
                                  if (!Get.isRegistered<QuizControllerDio>()) {
                                    Get.put(QuizControllerDio());
                                  }
                                  final quizCtrl =
                                      Get.find<QuizControllerDio>();
                                  await quizCtrl.loadQuizzes(
                                      courseKey: 'basic_grammar');
                                  Get.toNamed(
                                      AppRoutes.quizDio); // ✅ LANGSUNG KE DIO
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.quiz,
                                          color: Colors.indigo[700],
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Start Quiz',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Test your knowledge',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
