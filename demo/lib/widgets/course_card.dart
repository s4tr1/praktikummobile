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

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isButtonHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.025)
        .animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.primaryContainer.withValues(alpha: 0.9)
                : colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? colorScheme.primary.withValues(alpha: 0.25)
                    : Colors.transparent,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: widget.title,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(widget.image, height: 65, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 16,
                ),
              ),
              Text(
                "${widget.hours} Hours",
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              Text(
                "\$${widget.price}",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              MouseRegion(
                onEnter: (_) => setState(() => _isButtonHovered = true),
                onExit: (_) => setState(() => _isButtonHovered = false),
                child: AnimatedScale(
                  scale: _isButtonHovered ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseDetailPage(courseTitle: widget.title),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonHovered
                            ? colorScheme.primary.withValues(alpha: 0.9)
                            : colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: _isButtonHovered ? 6 : 2,
                      ),
                      child: const Text(
                        "View Course",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
