import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_data_service.dart';
import '../services/hive_service.dart';
import '../models/quiz_model.dart';

class AdminController extends GetxController {
  final SupabaseAuthService _authService = SupabaseAuthService();
  final SupabaseDataService _dataService = SupabaseDataService();
  final HiveService _hiveService = HiveService();

  // Login fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final errorMessage = ''.obs;
  final currentAdmin = Rxn<Map<String, dynamic>>();

  // Dashboard stats
  final dashboardStats = <String, dynamic>{}.obs;

  // Quiz management
  final quizzes = <QuizModel>[].obs;
  final isLoadingQuizzes = false.obs;

  // User results
  final userResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkAdminLogin();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ========== AUTHENTICATION ==========

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> checkAdminLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdminLoggedIn = prefs.getBool('is_admin_logged_in') ?? false;
    final adminEmail = prefs.getString('admin_email');

    if (isAdminLoggedIn && adminEmail != null) {
      // Auto login
      currentAdmin.value = {
        'email': adminEmail,
        'name': prefs.getString('admin_name') ?? 'Admin',
      };
      Get.offNamed('/admin/dashboard');
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Login with Supabase
      final admin = await _authService.loginAdmin(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (admin != null) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_admin_logged_in', true);
        await prefs.setString('admin_email', admin['email']);
        await prefs.setString('admin_name', admin['name']);

        currentAdmin.value = admin;

        // Navigate to admin dashboard
        Get.offNamed('/admin/dashboard');

        Get.snackbar(
          'Success',
          'Welcome back, ${admin['name']}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = 'Invalid email or password';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin_logged_in');
    await prefs.remove('admin_email');
    await prefs.remove('admin_name');

    currentAdmin.value = null;
    Get.offNamed('/admin/login');

    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ========== DASHBOARD ==========

  Future<void> loadDashboardStats() async {
    try {
      final stats = await _dataService.getDashboardStats();
      dashboardStats.value = stats;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard stats: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== QUIZ MANAGEMENT ==========

  Future<void> loadAllQuizzes() async {
    isLoadingQuizzes.value = true;
    try {
      final loadedQuizzes = await _dataService.getAllQuizzes();
      quizzes.value = loadedQuizzes;

      // Save to Hive cache
      await _hiveService.saveQuizzes(loadedQuizzes);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load quizzes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingQuizzes.value = false;
    }
  }

  Future<void> loadQuizzesByCourse(int courseId) async {
    isLoadingQuizzes.value = true;
    try {
      final loadedQuizzes = await _dataService.getQuizzesByCourse(courseId);
      quizzes.value = loadedQuizzes;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load quizzes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingQuizzes.value = false;
    }
  }

  Future<bool> createQuiz({
    required int courseId,
    required String question,
    required List<String> options,
    required int answerIndex,
    String difficulty = 'medium',
  }) async {
    try {
      final quiz = await _dataService.createQuiz(
        courseId: courseId,
        question: question,
        options: options,
        answerIndex: answerIndex,
        difficulty: difficulty,
      );

      Get.snackbar(
        'Success',
        'Quiz created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload quizzes
      await loadAllQuizzes();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create quiz: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateQuiz({
    required int id,
    required int courseId,
    required String question,
    required List<String> options,
    required int answerIndex,
    String difficulty = 'medium',
  }) async {
    try {
      await _dataService.updateQuiz(
        id: id,
        courseId: courseId,
        question: question,
        options: options,
        answerIndex: answerIndex,
        difficulty: difficulty,
      );

      Get.snackbar(
        'Success',
        'Quiz updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadAllQuizzes();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update quiz: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      await _dataService.deleteQuiz(id);

      Get.snackbar(
        'Success',
        'Quiz deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadAllQuizzes();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete quiz: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== USER RESULTS ==========

  Future<void> loadAllUsersResults() async {
    try {
      final results = await _dataService.getAllUsersResults();
      userResults.value = results;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user results: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String getCurrentAdminName() {
    return currentAdmin.value?['name'] ?? 'Admin';
  }
}
