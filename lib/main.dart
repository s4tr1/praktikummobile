import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ConatusApp());
}

class ConatusApp extends StatefulWidget {
  const ConatusApp({super.key});

  @override
  State<ConatusApp> createState() => _ConatusAppState();
}

class _ConatusAppState extends State<ConatusApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: _themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        useMaterial3: true,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        home: HomePage(
          onToggleTheme: toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
        ),
      ),
    );
  }
}
