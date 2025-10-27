import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var rememberMe = false.obs;
  var errorMessage = ''.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<Map<String, dynamic>>();

  final db = DBHelper.instance;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    _initializeDemoUser();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');

    // Only auto-fill if user was logged in with "Remember Me"
    if (isLoggedIn && savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe.value = true;
      // Don't auto-login here, let splash handle it
    }
  }

  /// Initialize demo user in database
  Future<void> _initializeDemoUser() async {
    try {
      final database = await db.database;

      // Check if demo user exists
      final result = await database.query(
        'users',
        where: 'email = ?',
        whereArgs: ['sarah@conatus.com'],
      );

      // If not exists, create demo user
      if (result.isEmpty) {
        await database.insert('users', {
          'name': 'Sarah',
          'email': 'sarah@conatus.com',
          // In production, you'd hash this password!
          'password': 'sarah123',
        });
      }
    } catch (e) {
      print('Error initializing demo user: $e');
    }
  }

  /// Login function
  Future<void> login({bool autoLogin = false}) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email and password are required';
      return;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final database = await db.database;

      // Query user from database
      final result = await database.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay

      if (result.isEmpty) {
        errorMessage.value = 'Invalid email or password';
        isLoading.value = false;
        return;
      }

      // Login successful
      final user = result.first;
      currentUser.value = user;
      isLoggedIn.value = true;

      // Save login credentials if remember me is checked
      if (rememberMe.value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);
        await prefs.setBool('is_logged_in', true);
      }

      if (!autoLogin) {
        Get.snackbar(
          'Success',
          'Welcome back, ${user['name']}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout function
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      currentUser.value = null;
      isLoggedIn.value = false;
      emailController.clear();
      passwordController.clear();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[600],
        colorText: Colors.white,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// Get current user name
  String getCurrentUserName() {
    return currentUser.value?['name'] ?? 'User';
  }
}
