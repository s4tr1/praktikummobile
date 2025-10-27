import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuizController>();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.loading.value) return const Center(child: CircularProgressIndicator());
          if (ctrl.quizzes.isEmpty) return const Center(child: Text('No quizzes found'));
          final q = ctrl.quizzes[ctrl.currentIndex.value];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                Text('${ctrl.currentIndex.value + 1}/${ctrl.quizzes.length}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (ctrl.currentIndex.value + 1) / ctrl.quizzes.length),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ...List.generate(q.options.length, (i) {
                        final selected = ctrl.selectedIndex.value == i;
                        return GestureDetector(
                          onTap: () => ctrl.selectOption(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: selected ? Colors.blue : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Expanded(child: Text(q.options[i], style: TextStyle(color: selected ? Colors.white : Colors.black))),
                              if (selected) const Icon(Icons.check, color: Colors.white)
                            ]),
                          ),
                        );
                      })
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: ctrl.selectedIndex.value >= 0 ? ctrl.nextQuestion : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Next'),
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
