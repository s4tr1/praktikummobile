import 'package:flutter/material.dart';
import '../widgets/rotating_logo.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseTitle;

  const CourseDetailPage({super.key, required this.courseTitle});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.courseTitle,
              child: RotatingLogo(controller: _controller), // ✅ perbaikan di sini
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to your course!",
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
