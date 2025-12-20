import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../models/branch_model.dart';
import '../models/vocabulary_model.dart'; // ✅ TAMBAHKAN INI!
import '../config/supabase_config.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // ========== INITIALIZATION ==========

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
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BranchModelAdapter());
    }
    // ✅ VOCABULARY ADAPTER
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(VocabularyWordAdapter());
    }

    // Open boxes
    await Hive.openBox<UserModel>(SupabaseConfig.userBoxName);
    await Hive.openBox<CourseModel>(SupabaseConfig.courseBoxName);
    await Hive.openBox<QuizModel>(SupabaseConfig.quizBoxName);
    await Hive.openBox(SupabaseConfig.settingsBoxName);
    await Hive.openBox<BranchModel>('branch_box');
    await Hive.openBox<VocabularyWord>('vocabulary_box'); // ✅ VOCABULARY BOX
  }

  // ========== USER CACHE ==========

  Box<UserModel> get userBox => Hive.box<UserModel>(SupabaseConfig.userBoxName);

  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user);
  }

  UserModel? getCachedUser() {
    return userBox.get('current_user');
  }

  Future<void> clearUser() async {
    await userBox.delete('current_user');
  }

  // ========== COURSE CACHE ==========

  Box<CourseModel> get courseBox =>
      Hive.box<CourseModel>(SupabaseConfig.courseBoxName);

  Future<void> saveCourses(List<CourseModel> courses) async {
    await courseBox.clear();
    for (var course in courses) {
      await courseBox.put(course.id, course);
    }
  }

  List<CourseModel> getCachedCourses() {
    return courseBox.values.toList();
  }

  Future<void> updateCourse(CourseModel course) async {
    await courseBox.put(course.id, course);
  }

  Future<void> clearCourses() async {
    await courseBox.clear();
  }

  // ========== QUIZ CACHE ==========

  Box<QuizModel> get quizBox => Hive.box<QuizModel>(SupabaseConfig.quizBoxName);

  Future<void> saveQuizzes(List<QuizModel> quizzes) async {
    await quizBox.clear();
    for (var quiz in quizzes) {
      await quizBox.put(quiz.id, quiz);
    }
  }

  List<QuizModel> getCachedQuizzes() {
    return quizBox.values.toList();
  }

  List<QuizModel> getCachedQuizzesByCourse(int courseId) {
    return quizBox.values.where((quiz) => quiz.courseId == courseId).toList();
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await quizBox.put(quiz.id, quiz);
  }

  Future<void> deleteQuiz(String quizId) async {
    await quizBox.delete(quizId);
  }

  Future<void> clearQuizzes() async {
    await quizBox.clear();
  }

  // ========== BRANCH CACHE ==========

  Box<BranchModel> get branchBox => Hive.box<BranchModel>('branch_box');

  Future<void> saveBranches(List<BranchModel> branches) async {
    await branchBox.clear();
    for (var branch in branches) {
      await branchBox.put(branch.id, branch);
    }
  }

  List<BranchModel> getCachedBranches() {
    return branchBox.values.toList();
  }

  BranchModel? getBranchById(int id) {
    return branchBox.get(id);
  }

  Future<void> updateBranch(BranchModel branch) async {
    await branchBox.put(branch.id, branch);
  }

  Future<void> clearBranches() async {
    await branchBox.clear();
  }

  // ========== VOCABULARY CACHE (NEW) ==========

  Box<VocabularyWord> get vocabularyBox =>
      Hive.box<VocabularyWord>('vocabulary_box');

  Future<void> saveVocabulary(List<VocabularyWord> words) async {
    await vocabularyBox.clear();
    for (var word in words) {
      await vocabularyBox.put(word.id, word);
    }
  }

  List<VocabularyWord> getCachedVocabulary() {
    return vocabularyBox.values.toList();
  }

  Future<void> updateVocabularyWord(VocabularyWord word) async {
    await vocabularyBox.put(word.id, word);
  }

  Future<void> clearVocabulary() async {
    await vocabularyBox.clear();
  }

  // ========== SETTINGS ==========

  Box get settingsBox => Hive.box(SupabaseConfig.settingsBoxName);

  Future<void> saveTheme(String theme) async {
    await settingsBox.put('app_theme', theme);
  }

  String getTheme() {
    return settingsBox.get('app_theme', defaultValue: 'light') as String;
  }

  Future<void> saveRememberMe(bool value) async {
    await settingsBox.put('remember_me', value);
  }

  bool getRememberMe() {
    return settingsBox.get('remember_me', defaultValue: false) as bool;
  }

  Future<void> saveLastSync(DateTime dateTime) async {
    await settingsBox.put('last_sync', dateTime.toIso8601String());
  }

  DateTime? getLastSync() {
    final syncStr = settingsBox.get('last_sync') as String?;
    return syncStr != null ? DateTime.parse(syncStr) : null;
  }

  // ========== CLEAR ALL DATA ==========

  Future<void> clearAllData() async {
    await clearUser();
    await clearCourses();
    await clearQuizzes();
    await clearBranches();
    await clearVocabulary(); // ✅ CLEAR VOCABULARY
    await settingsBox.clear();
  }

  Future<void> closeAll() async {
    await Hive.close();
  }
}
