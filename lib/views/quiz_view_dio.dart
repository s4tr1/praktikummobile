import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller_dio.dart';

class QuizViewDio extends StatelessWidget {
  const QuizViewDio({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizControllerDio>();
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.indigo,
                      ),
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
                        color: ctrl.showTranslated.value
                            ? Colors.indigo
                            : Colors.grey[700],
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
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
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
                  backgroundColor: Colors.indigo[100],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.indigo[600]!),
                ),
                const SizedBox(height: 20),

                // Question card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo[100]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Obx(() {
                        if (ctrl.translatingQuestion.value) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.indigo,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Translating...',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayQuestion,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            if (ctrl.showTranslated.value)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.indigo[700],
                                  size: 16,
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),

                      // Options
                      Obx(() {
                        if (ctrl.translatingOptions.value) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.indigo,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Translating options...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
