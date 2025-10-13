import 'package:flutter/material.dart';
import '../widgets/course_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.isDarkMode ? Colors.white : Colors.indigo.shade900;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [const Color(0xFF0A1C2B), const Color(0xFF193B59)]
                : [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hello, Ava!",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          onPressed: widget.onToggleTheme,
                          tooltip: "Toggle Theme",
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Banner
                    _buildBanner(
                      color: widget.isDarkMode ? Colors.blueGrey.shade700 : Colors.indigo.shade300,
                      title: "How do you want to start?",
                      buttonText: "Take a Test",
                    ),
                    const SizedBox(height: 16),
                    _buildBanner(
                      color: widget.isDarkMode ? Colors.teal.shade600 : Colors.indigo.shade400,
                      title: "Free online course",
                      buttonText: "Start learning",
                    ),

                    const SizedBox(height: 28),

                    // Grid Course Cards
                    Text(
                      "Skills-Based Courses",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        double aspectRatio = 0.78; // ✅ lebih tinggi biar muat tombol

                        if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                          aspectRatio = 0.9;
                        }
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                          aspectRatio = 1.0;
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspectRatio, // ✅ cegah overflow
                          children: const [
                            CourseCard(title: "Writing", price: 200, hours: 100, image: "assets/writing.jpg"),
                            CourseCard(title: "Reading", price: 450, hours: 120, image: "assets/reading.jpeg"),
                            CourseCard(title: "Listening", price: 300, hours: 360, image: "assets/listening.jpg"),
                            CourseCard(title: "Speaking", price: 280, hours: 80, image: "assets/speaking.jpg"),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Promo Card
                    ScaleTransition(
                      scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Special Discounts\n20% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner({
    required Color color,
    required String title,
    required String buttonText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
