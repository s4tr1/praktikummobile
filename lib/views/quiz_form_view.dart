import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import 'dart:convert';

class QuizFormView extends StatefulWidget {
  const QuizFormView({super.key});

  @override
  State<QuizFormView> createState() => _QuizFormViewState();
}

class _QuizFormViewState extends State<QuizFormView> {
  final _formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();

  int selectedCourseId = 1;
  int correctAnswerIndex = 0;
  String difficulty = 'medium';

  bool isEditMode = false;
  int? editQuizId;

  @override
  void initState() {
    super.initState();

    // Check if in edit mode
    final args = Get.arguments;
    if (args != null && args['mode'] == 'edit') {
      isEditMode = true;
      final quiz = args['quiz'];

      editQuizId = int.parse(quiz.id);
      questionController.text = quiz.question;

      if (quiz.options.length >= 1) option1Controller.text = quiz.options[0];
      if (quiz.options.length >= 2) option2Controller.text = quiz.options[1];
      if (quiz.options.length >= 3) option3Controller.text = quiz.options[2];
      if (quiz.options.length >= 4) option4Controller.text = quiz.options[3];

      correctAnswerIndex = quiz.answerIndex;
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        title: Text(
          isEditMode ? 'Edit Quiz' : 'Create New Quiz',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Course Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: selectedCourseId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Basic Grammar')),
                        // Add more courses as needed
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCourseId = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: questionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter quiz question',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Answer Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOptionField('A', option1Controller, 0),
                    const SizedBox(height: 12),
                    _buildOptionField('B', option2Controller, 1),
                    const SizedBox(height: 12),
                    _buildOptionField('C', option3Controller, 2),
                    const SizedBox(height: 12),
                    _buildOptionField('D', option4Controller, 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Difficulty
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: difficulty,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('Easy')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'hard', child: Text('Hard')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          difficulty = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () => _submitForm(adminCtrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEditMode ? 'Update Quiz' : 'Create Quiz',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(
      String label, TextEditingController controller, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<int>(
          value: index,
          groupValue: correctAnswerIndex,
          onChanged: (value) {
            setState(() {
              correctAnswerIndex = value!;
            });
          },
          activeColor: Colors.green,
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Option $label',
              hintText: 'Enter option $label',
              border: const OutlineInputBorder(),
              suffixIcon: correctAnswerIndex == index
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter option $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm(AdminController adminCtrl) async {
    if (_formKey.currentState!.validate()) {
      final options = [
        option1Controller.text.trim(),
        option2Controller.text.trim(),
        option3Controller.text.trim(),
        option4Controller.text.trim(),
      ];

      bool success;
      if (isEditMode) {
        success = await adminCtrl.updateQuiz(
          id: editQuizId!,
          courseId: selectedCourseId,
          question: questionController.text.trim(),
          options: options,
          answerIndex: correctAnswerIndex,
          difficulty: difficulty,
        );
      } else {
        success = await adminCtrl.createQuiz(
          courseId: selectedCourseId,
          question: questionController.text.trim(),
          options: options,
          answerIndex: correctAnswerIndex,
          difficulty: difficulty,
        );
      }

      if (success) {
        Get.back();
      }
    }
  }
}