import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  /// Show success notification
  static void success({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show error notification
  static void error({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show info notification
  static void info({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue[600],
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.info_outline,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show warning notification
  static void warning({
    required String title,
    required String message,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange[600],
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.warning_amber_outlined,
        color: Colors.white,
        size: 28,
      ),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show loading notification (for long operations)
  static void loading({
    required String title,
    String message = 'Please wait...',
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 30), // Long duration
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.grey[600],
      progressIndicatorValueColor:
          const AlwaysStoppedAnimation<Color>(Colors.white),
      isDismissible: false,
    );
  }

  /// Dismiss all snackbars
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  }
}
