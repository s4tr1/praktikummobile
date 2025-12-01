import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_auth_service.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var rememberMe = false.obs;
  var errorMessage = ''.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();

  final _authService = SupabaseAuthService();
  final _hiveService = HiveService();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      // Check Supabase session
      if (_authService.isUserLoggedIn()) {
        final authUser = _authService.getCurrentAuthUser();
        if (authUser != null) {
          // Get user profile from cache or database
          var user = _hiveService.getCachedUser();

          if (user == null) {
            // Fetch from Supabase
            user = await _authService.getUserProfile(authUser.id);
            if (user != null) {
              await _hiveService.saveUser(user);
            }
          }

          if (user != null) {
            currentUser.value = user;
            isLoggedIn.value = true;
          }
        }
      }

      // Check SharedPreferences for remember me
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedRememberMe = prefs.getBool('remember_me') ?? false;

      if (savedEmail != null && savedRememberMe) {
        emailController.text = savedEmail;
        rememberMe.value = true;
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  /// Login function with Supabase
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
      // Login with Supabase
      final user = await _authService.loginUser(
        email: email,
        password: password,
      );

      if (user == null) {
        errorMessage.value = 'Invalid email or password';
        isLoading.value = false;
        return;
      }

      // Save to local cache
      await _hiveService.saveUser(user);
      currentUser.value = user;
      isLoggedIn.value = true;

      // Save login credentials if remember me is checked
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe.value) {
        await prefs.setString('user_email', email);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('user_email');
        await prefs.setBool('remember_me', false);
      }

      if (!autoLogin) {
        Get.snackbar(
          'Welcome Back! 👋',
          'Hi ${user.name}, you\'re successfully logged in!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline,
              color: Colors.white, size: 28),
          shouldIconPulse: true,
          barBlur: 20,
        );
      }

      // Navigate to home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout function
  Future<void> logout() async {
    try {
      // Logout from Supabase
      await _authService.logoutUser();

      // Clear local cache
      await _hiveService.clearUser();

      // Clear SharedPreferences (keep remember me email if checked)
      final prefs = await SharedPreferences.getInstance();
      if (!rememberMe.value) {
        await prefs.remove('user_email');
      }
      await prefs.remove('is_logged_in');

      currentUser.value = null;
      isLoggedIn.value = false;
      passwordController.clear();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Logged Out',
        'See you soon! 👋',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.exit_to_app, color: Colors.white),
      );
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    return currentUser.value?.name ?? 'User';
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return currentUser.value?.id;
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _authService.updateUserProfile(
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
      );

      // Update local cache
      if (currentUser.value != null) {
        if (name != null) currentUser.value!.name = name;
        if (avatarUrl != null) currentUser.value!.avatarUrl = avatarUrl;
        await _hiveService.saveUser(currentUser.value!);
        currentUser.refresh();
      }

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar(
        'Success',
        'Password reset email sent! Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
