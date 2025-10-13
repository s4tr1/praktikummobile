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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
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
    final screenWidth = MediaQuery.of(context).size.width;

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
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Hello, Ava!",
                            style: TextStyle(
                              color: textColor,
                              fontSize: screenWidth < 600 ? 24 : 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: colorScheme.primary,
                            size: screenWidth < 600 ? 24 : 28,
                          ),
                          onPressed: widget.onToggleTheme,
                          tooltip: "Toggle Theme",
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth < 600 ? 12 : 16),

                    // Banners
                    _buildBanner(
                      context,
                      color: widget.isDarkMode
                          ? Colors.blueGrey.shade700
                          : Colors.indigo.shade300,
                      title: "How do you want to start?",
                      buttonText: "Take a Test",
                    ),
                    SizedBox(height: screenWidth < 600 ? 12 : 16),
                    _buildBanner(
                      context,
                      color: widget.isDarkMode
                          ? Colors.teal.shade600
                          : Colors.indigo.shade400,
                      title: "Free online course",
                      buttonText: "Start learning",
                    ),

                    SizedBox(height: screenWidth < 600 ? 20 : 28),

                    // Grid Course Cards
                    Text(
                      "Skills-Based Courses",
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: screenWidth < 600 ? 12 : 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;
                        double aspectRatio;
                        double crossAxisSpacing;
                        double mainAxisSpacing;

                        if (constraints.maxWidth < 600) {
                          // Mobile
                          crossAxisCount = 2;
                          aspectRatio = 0.75;
                          crossAxisSpacing = 12;
                          mainAxisSpacing = 12;
                        } else if (constraints.maxWidth < 900) {
                          // Tablet
                          crossAxisCount = 3;
                          aspectRatio = 0.80;
                          crossAxisSpacing = 14;
                          mainAxisSpacing = 14;
                        } else if (constraints.maxWidth < 1200) {
                          // Small Desktop
                          crossAxisCount = 4;
                          aspectRatio = 0.85;
                          crossAxisSpacing = 16;
                          mainAxisSpacing = 16;
                        } else {
                          // Large Desktop
                          crossAxisCount = 4;
                          aspectRatio = 0.88;
                          crossAxisSpacing = 18;
                          mainAxisSpacing = 18;
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                          childAspectRatio: aspectRatio,
                          children: const [
                            CourseCard(
                              title: "Writing",
                              price: 200,
                              hours: 100,
                              image: "assets/writing.jpg",
                            ),
                            CourseCard(
                              title: "Reading",
                              price: 450,
                              hours: 120,
                              image: "assets/reading.jpeg",
                            ),
                            CourseCard(
                              title: "Listening",
                              price: 300,
                              hours: 360,
                              image: "assets/listening.jpg",
                            ),
                            CourseCard(
                              title: "Speaking",
                              price: 280,
                              hours: 80,
                              image: "assets/speaking.jpg",
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: screenWidth < 600 ? 20 : 30),

                    // Promo Card
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth < 600 ? 18 : 24),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Special Discounts\n20% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth < 600 ? 20 : 26,
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

  Widget _buildBanner(
    BuildContext context, {
    required Color color,
    required String title,
    required String buttonText,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: screenWidth < 600
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                ),
              ],
            )
          : Row(
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
                const SizedBox(width: 12),
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
