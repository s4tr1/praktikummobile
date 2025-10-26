import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';
import 'utils/app_colors.dart';
import 'utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ConatusApp());
}

class ConatusApp extends StatelessWidget {
  const ConatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(),
    );
  }
}
