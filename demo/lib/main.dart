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
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conatus Academy',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(onToggleTheme: toggleTheme, isDarkMode: _themeMode == ThemeMode.dark),
    );
  }
}
