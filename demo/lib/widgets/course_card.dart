import 'package:flutter/material.dart';
import '../pages/course_detail_page.dart';

class CourseCard extends StatefulWidget {
  final String title;
  final int hours;
  final int price;
  final String image;

  const CourseCard({
    super.key,
    required this.title,
    required this.hours,
    required this.price,
    required this.image,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) {
        setState(() => _isTapped = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailPage(courseTitle: widget.title),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _isTapped ? Colors.teal.shade200 : Colors.teal.shade50,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (_isTapped)
              const BoxShadow(color: Colors.teal, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.title,
              child: Image.asset(widget.image, height: 60),
            ),
            const SizedBox(height: 10),
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${widget.hours} Hours"),
            Text("\$${widget.price}"),
          ],
        ),
      ),
    );
  }
}
