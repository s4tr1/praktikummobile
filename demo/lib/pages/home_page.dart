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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan animasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 500),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.indigo.shade900,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      child: const Text("Hello, Ava!"),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: widget.isDarkMode ? Colors.white : Colors.indigo,
                        size: 28,
                      ),
                      onPressed: widget.onToggleTheme,
                      tooltip: "Toggle Theme",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Banner animasi
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: widget.isDarkMode
                      ? _buildBanner(
                    color: Colors.blueGrey.shade800,
                    title: "How do you want to start?",
                    buttonText: "Take a Test",
                  )
                      : _buildBanner(
                    color: Colors.indigo.shade200,
                    title: "How do you want to start?",
                    buttonText: "Take a Test",
                  ),
                ),

                const SizedBox(height: 12),

                _buildBanner(
                  color: widget.isDarkMode ? Colors.teal.shade700 : Colors.indigo.shade300,
                  title: "Free online course",
                  buttonText: "Start learning",
                ),

                const SizedBox(height: 24),

                Text(
                  "Skills-Based Courses",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    CourseCard(title: "Writing", price: 200, hours: 100, image: "assets/writing.jpg"),
                    CourseCard(title: "Reading", price: 450, hours: 120, image: "assets/reading.jpeg"),
                    CourseCard(title: "Listening", price: 300, hours: 360, image: "assets/listening.jpg"),
                    CourseCard(title: "Speaking", price: 280, hours: 80, image: "assets/speaking.jpg"),
                  ],
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Special Discounts\n20%",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
