import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_auth_service.dart';
import '../services/hive_service.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var errorMessage = ''.obs;

  final _authService = SupabaseAuthService();
  final _hiveService = HiveService();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Register new user with Supabase
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Clear previous error
    errorMessage.value = '';

    // Validation
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errorMessage.value = 'All fields are required';
      return;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email';
      return;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    // Start loading
    isLoading.value = true;
    print('🚀 RegisterController: Starting registration...');

    try {
      // Call auth service
      print('📞 RegisterController: Calling auth service...');
      final user = await _authService.registerUser(
        email: email,
        password: password,
        name: name,
      );

      print('✅ RegisterController: Registration completed!');
      print('   User: ${user?.name ?? "null"}');

      // Stop loading
      isLoading.value = false;

      // Save to cache if user exists
      if (user != null) {
        try {
          await _hiveService.saveUser(user);
          print('✅ User cached locally');
        } catch (cacheError) {
          print('⚠️ Cache error (non-critical): $cacheError');
        }
      }

      // ============ SHOW SUCCESS NOTIFICATION ============
      print('🎉 Showing success notification...');
      Get.snackbar(
        'Registration Successful! 🎉',
        'Your account has been created. Please login to continue.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50), // Green
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
        shouldIconPulse: true,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );

      // Clear form fields
      print('🧹 Clearing form...');
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Wait a moment then navigate back
      await Future.delayed(const Duration(milliseconds: 800));
      print('⬅️ Navigating back to login...');
      Get.back();

      print('✅ Registration flow completed successfully!');
    } catch (e) {
      print('❌ RegisterController: Error caught!');
      print('   Error type: ${e.runtimeType}');
      print('   Error message: $e');

      isLoading.value = false;

      final errorString = e.toString().toLowerCase();

      // Check if it's a success message disguised as error
      if (errorString.contains('account created successfully') ||
          errorString.contains('please try logging in') ||
          errorString.contains('registration successful')) {
        print(
            '🎉 Success case detected in error! Showing success notification...');

        // This is actually SUCCESS!
        Get.snackbar(
          'Registration Successful! 🎉',
          'Your account has been created. Please login to continue.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
          shouldIconPulse: true,
        );

        // Clear form
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        await Future.delayed(const Duration(milliseconds: 800));
        Get.back();
      } else {
        // Real error
        print('❌ Real error detected');
        errorMessage.value = e.toString().replaceAll('Exception: ', '');

        // Show error snackbar too
        Get.snackbar(
          'Registration Failed',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error, color: Colors.white, size: 30),
        );
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
}
