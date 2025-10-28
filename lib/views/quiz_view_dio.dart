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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'DIO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
                        color: Colors.green,
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
                            : Icons.flash_on,
                        color: ctrl.showTranslated.value
                            ? Colors.green
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Loading with DIO...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
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
                // Info Banner DIO
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.green[700], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Powered by DIO - Parallel translation enabled!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

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
                  backgroundColor: Colors.green[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                ),
                const SizedBox(height: 20),

                // Question card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
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
                                  color: Colors.green,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Translating with DIO...',
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
                                  color: Colors.green[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green[700],
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
                                  color: Colors.green,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Translating options in parallel...',
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
                                      ? Colors.green
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.green
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

                // Translation Speed Info (if translated)
                Obx(() {
                  if (ctrl.showTranslated.value) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed, color: Colors.green[700], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Parallel translation completed',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Next button
                ElevatedButton(
                  onPressed:
                      ctrl.selectedIndex.value >= 0 ? ctrl.nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.green,
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
