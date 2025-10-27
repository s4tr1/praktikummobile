import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final courseCtrl = Get.find<CourseController>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Hi, Sarah', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(backgroundImage: AssetImage('assets/images/conatus_logo.png')),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1B50), Color(0xFF087E8B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // progress circle (simple)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Goal - 1h/day', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          Text('50%', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // placeholder profile
                    CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/conatus_logo.png'))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Continue Course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Obx(() {
                        final courses = courseCtrl.courses;
                        if (courses.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final c = courses.first;
                        return GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.course, arguments: c.toMap());
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/conatus_logo.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.toNamed(AppRoutes.course, arguments: c.toMap());
                                            },
                                            child: const Text('Continue'),
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
                      }),
                      const SizedBox(height: 16),
                      const Text('Popular Courses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              leading: Image.asset('assets/images/conatus_logo.png', width: 56),
                              title: const Text('Speaking'),
                              subtitle: const Text('Improve fluency'),
                              trailing: ElevatedButton(onPressed: () {}, child: const Text('Enroll')),
                            ),
                            ListTile(
                              leading: Image.asset('assets/images/conatus_logo.png', width: 56),
                              title: const Text('Vocabulary'),
                              subtitle: const Text('Build vocab'),
                              trailing: ElevatedButton(onPressed: () {}, child: const Text('Enroll')),
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
