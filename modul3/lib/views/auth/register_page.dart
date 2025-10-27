import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  String selectedRole = "user";
  bool isLoading = false;

  @override
  void dispose() {
    usernameC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

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
                CustomTextField(
                  controller: passwordC,
                  hint: "Password",
                  obscure: true,
                ),
                const SizedBox(height: 16),

                // ✅ Dropdown dengan setState
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "user", child: Text("User")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ Button dengan loading state
                isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: "Register",
                        onPressed: () async {
                          // Validasi input
                          if (usernameC.text.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Username cannot be empty",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (passwordC.text.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Password cannot be empty",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (passwordC.text.length < 6) {
                            Get.snackbar(
                              "Error",
                              "Password must be at least 6 characters",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            bool success = await authController.register(
                              usernameC.text.trim(),
                              passwordC.text.trim(),
                              selectedRole,
                            );

                            setState(() => isLoading = false);

                            if (success) {
                              Get.back();
                              Get.snackbar(
                                "Success",
                                "Registration successful! Please login",
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                "Error",
                                "Username already exists",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            Get.snackbar(
                              "Error",
                              "Registration failed: ${e.toString()}",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),

                const SizedBox(height: 16),

                // ✅ Link ke login page
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Already have an account? Login here",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
