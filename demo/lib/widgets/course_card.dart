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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.05 : 1.0) // efek membesar saat hover
            ..translate(0, _isTapped ? 3.0 : 0.0), // sedikit turun saat diklik
          decoration: BoxDecoration(
            color: _isTapped
                ? colorScheme.primaryContainer.withOpacity(0.6)
                : _isHovered
                    ? colorScheme.primaryContainer.withOpacity(0.9)
                    : colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
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
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                "${widget.hours} Hours",
                style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
              ),
              Text(
                "\$${widget.price}",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
