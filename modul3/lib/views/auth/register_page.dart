import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final TextEditingController usernameC = TextEditingController();
    final TextEditingController passwordC = TextEditingController();
    String selectedRole = "user";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(controller: usernameC, hint: "Username"),
                const SizedBox(height: 16),
                CustomTextField(controller: passwordC,  hint: "Password", obscure: true),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: "user", child: Text("User")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (value) => selectedRole = value!,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Register",
                  onPressed: () async {
                    bool success = await authController.register(usernameC.text, passwordC.text, selectedRole);
                    if (success) {
                      Get.back();
                      Get.snackbar("Success", "Registration successful");
                    } else {
                      Get.snackbar("Error", "Username already exists");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
