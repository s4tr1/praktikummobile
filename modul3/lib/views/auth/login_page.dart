import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../user/user_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'register_page.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final TextEditingController usernameC = TextEditingController();
    final TextEditingController passwordC = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back!",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(controller: usernameC, hintText: "Username"),
              const SizedBox(height: 16),
              CustomTextField(controller: passwordC, hintText: "Password", obscureText: true),
              const SizedBox(height: 24),
              CustomButton(
                text: "Login",
                onPressed: () async {
                  bool success = await authController.login(usernameC.text, passwordC.text);
                  if (success) {
                    if (authController.currentUser.value!.role == "admin") {
                      Get.off(() => const AdminDashboard());
                    } else {
                      Get.off(() => const UserDashboard());
                    }
                  } else {
                    Get.snackbar("Error", "Invalid username or password");
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.to(() => const RegisterPage()),
                child: const Text("Don’t have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
