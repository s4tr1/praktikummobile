import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'controllers/course_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/admin_controller.dart'; // ADD THIS LINE
import 'controllers/quiz_controller.dart';
import 'controllers/quiz_controller_dio.dart';
import 'services/hive_service.dart';
import 'config/supabase_config.dart';
import 'views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');

    // Initialize Hive
    await HiveService().init();
    print('✅ Hive initialized successfully');

    // NOTE: Keep SQLite initialization for backward compatibility/migration
    // You can remove this later after data migration is complete
    // await DBHelper.instance.initDB();

    // Initialize controllers
    Get.put(CourseController());
    Get.put(AuthController(), permanent: true);

    // Register AdminController as lazy (will initialize when needed)
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);

    // Lazy load quiz controllers
    Get.lazyPut<QuizController>(() => QuizController());
    Get.lazyPut<QuizControllerDio>(() => QuizControllerDio());

    runApp(const ConatusApp());
  } catch (e) {
    print('❌ Initialization error: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class ConatusApp extends StatelessWidget {
  const ConatusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Conatus Academy',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        // Add custom theme if needed
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087E8B),
          brightness: Brightness.light,
        ),
      ),
      home: const SplashView(),
    );
  }
}

// Error widget if initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
