import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() {
          if (ctrl.quizzes.isEmpty) return const SizedBox.shrink();
          return Chip(
            label: Text(
              ctrl.currentLanguage.value == 'en'
                  ? '🇬🇧 English'
                  : '🇮🇩 Indonesian',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: ctrl.currentLanguage.value == 'en'
                ? Colors.blue[100]
                : Colors.red[100],
          );
        }),
        actions: [
          Obx(() {
            if (ctrl.quizzes.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Obx(() {
                  if (ctrl.translatingQuestion.value ||
                      ctrl.translatingOptions.value) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return Tooltip(
                    message:
                        'Translate to ${ctrl.currentLanguage.value == 'en' ? 'Indonesian' : 'English'}',
                    child: IconButton(
                      icon: Icon(
                        ctrl.showTranslated.value
                            ? Icons.language
                            : Icons.translate,
                        color: ctrl.showTranslated.value ? Colors.blue : null,
                      ),
                      onPressed: () {
                        if (ctrl.translatedQuestion.value.isEmpty &&
                            ctrl.translatedOptions.isEmpty) {
                          ctrl.translateAll();
                        } else {
                          ctrl.toggleShowTranslated();
                        }
                      },
                    ),
                  );
                }),
              ),
            );
          })
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.quizzes.isEmpty) {
            return const Center(child: Text('No quizzes found'));
          }

          final q = ctrl.quizzes[ctrl.currentIndex.value];
          final displayQuestion = ctrl.getDisplayQuestion();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                // Question counter
                Text(
                  '${ctrl.currentIndex.value + 1}/${ctrl.quizzes.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (ctrl.currentIndex.value + 1) / ctrl.quizzes.length,
                  minHeight: 6,
                ),
                const SizedBox(height: 20),

                // Question card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Obx(() {
                        if (ctrl.translatingQuestion.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Text(
                          displayQuestion,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Options
                      Obx(() {
                        if (ctrl.translatingOptions.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Column(
                          children: List.generate(q.options.length, (i) {
                            final selected = ctrl.selectedIndex.value == i;
                            final displayOption = ctrl.getDisplayOption(i);

                            return GestureDetector(
                              onTap: () => ctrl.selectOption(i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.indigo
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.indigo
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayOption,
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(Icons.check_circle,
                                          color: Colors.white)
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ],
                  ),
                ),
                const Spacer(),

                // Next button
                ElevatedButton(
                  onPressed:
                      ctrl.selectedIndex.value >= 0 ? ctrl.nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.indigo,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        }),
      ),
    );
  }
}
