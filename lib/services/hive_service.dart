import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../config/supabase_config.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // ========== INITIALIZATION ==========

  /// Initialize Hive and register adapters
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CourseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuizModelAdapter());
    }

    // Open boxes
    await Hive.openBox<UserModel>(SupabaseConfig.userBoxName);
    await Hive.openBox<CourseModel>(SupabaseConfig.courseBoxName);
    await Hive.openBox<QuizModel>(SupabaseConfig.quizBoxName);
    await Hive.openBox(SupabaseConfig.settingsBoxName);
  }

  // ========== USER CACHE ==========

  Box<UserModel> get userBox => Hive.box<UserModel>(SupabaseConfig.userBoxName);

  /// Save current user to cache
  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user);
  }

  /// Get cached user
  UserModel? getCachedUser() {
    return userBox.get('current_user');
  }

  /// Clear user cache
  Future<void> clearUser() async {
    await userBox.delete('current_user');
  }

  // ========== COURSE CACHE ==========

  Box<CourseModel> get courseBox => Hive.box<CourseModel>(SupabaseConfig.courseBoxName);

  /// Save courses to cache
  Future<void> saveCourses(List<CourseModel> courses) async {
    await courseBox.clear();
    for (var course in courses) {
      await courseBox.put(course.id, course);
    }
  }

  /// Get cached courses
  List<CourseModel> getCachedCourses() {
    return courseBox.values.toList();
  }

  /// Update single course
  Future<void> updateCourse(CourseModel course) async {
    await courseBox.put(course.id, course);
  }

  /// Clear courses cache
  Future<void> clearCourses() async {
    await courseBox.clear();
  }

  // ========== QUIZ CACHE ==========

  Box<QuizModel> get quizBox => Hive.box<QuizModel>(SupabaseConfig.quizBoxName);

  /// Save quizzes to cache
  Future<void> saveQuizzes(List<QuizModel> quizzes) async {
    await quizBox.clear();
    for (var quiz in quizzes) {
      await quizBox.put(quiz.id, quiz);
    }
  }

  /// Get cached quizzes
  List<QuizModel> getCachedQuizzes() {
    return quizBox.values.toList();
  }

  /// Get quizzes by course
  List<QuizModel> getCachedQuizzesByCourse(int courseId) {
    return quizBox.values
        .where((quiz) => quiz.courseId == courseId)
        .toList();
  }

  /// Update single quiz
  Future<void> updateQuiz(QuizModel quiz) async {
    await quizBox.put(quiz.id, quiz);
  }

  /// Delete quiz
  Future<void> deleteQuiz(String quizId) async {
    await quizBox.delete(quizId);
  }

  /// Clear quizzes cache
  Future<void> clearQuizzes() async {
    await quizBox.clear();
  }

  // ========== SETTINGS (using shared_preferences alternative) ==========

  Box get settingsBox => Hive.box(SupabaseConfig.settingsBoxName);

  /// Save app theme
  Future<void> saveTheme(String theme) async {
    await settingsBox.put('app_theme', theme);
  }

  /// Get app theme
  String getTheme() {
    return settingsBox.get('app_theme', defaultValue: 'light') as String;
  }

  /// Save remember me status
  Future<void> saveRememberMe(bool value) async {
    await settingsBox.put('remember_me', value);
  }

  /// Get remember me status
  bool getRememberMe() {
    return settingsBox.get('remember_me', defaultValue: false) as bool;
  }

  /// Save last sync time
  Future<void> saveLastSync(DateTime dateTime) async {
    await settingsBox.put('last_sync', dateTime.toIso8601String());
  }

  /// Get last sync time
  DateTime? getLastSync() {
    final syncStr = settingsBox.get('last_sync') as String?;
    return syncStr != null ? DateTime.parse(syncStr) : null;
  }

  // ========== CLEAR ALL DATA ==========

  /// Clear all cached data (for logout)
  Future<void> clearAllData() async {
    await clearUser();
    await clearCourses();
    await clearQuizzes();
    await settingsBox.clear();
  }

  /// Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }
}