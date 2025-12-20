import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary_model.dart';

class VocabularyView extends StatelessWidget {
  const VocabularyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(VocabularyController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Vocabulary', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context, ctrl),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(ctrl.errorMessage.value),
                ElevatedButton(
                  onPressed: () => ctrl.loadVocabulary(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Progress Header
            _buildProgressHeader(ctrl),
            
            // Quick Actions
            _buildQuickActions(ctrl),

            // Word List
            Expanded(
              child: ctrl.filteredWords.isEmpty
                  ? _buildEmptyState(ctrl)
                  : _buildWordList(ctrl),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProgressHeader(VocabularyController ctrl) {
    return Obx(() {
      final prog = ctrl.progress.value;
      if (prog == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.book,
                  label: 'Total',
                  value: '${prog.totalWords}',
                  color: Colors.white,
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  label: 'Learned',
                  value: '${prog.learnedWords}',
                  color: Colors.greenAccent,
                ),
                _StatCard(
                  icon: Icons.star,
                  label: 'Mastered',
                  value: '${prog.masteredWords}',
                  color: Colors.amberAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: prog.overallProgress / 100,
              minHeight: 6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${prog.overallProgress.toStringAsFixed(1)}% Complete',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions(VocabularyController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => ctrl.startQuiz(),
              icon: const Icon(Icons.quiz),
              label: const Text('Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ctrl.startFlashcard();
                _showFlashcardDialog(Get.context!, ctrl);
              },
              icon: const Icon(Icons.style),
              label: const Text('Flashcard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(VocabularyController ctrl) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ctrl.filteredWords.length,
      itemBuilder: (context, index) {
        final word = ctrl.filteredWords[index];
        return _WordCard(word: word, ctrl: ctrl);
      },
    );
  }

  Widget _buildEmptyState(VocabularyController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No words found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ctrl.clearFilters(),
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, VocabularyController ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Words'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter word or meaning...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) => ctrl.setSearchQuery(query),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctrl.setSearchQuery('');
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, VocabularyController ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Words'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Level:', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'beginner', 'intermediate', 'advanced']
                  .map((level) => ChoiceChip(
                        label: Text(level),
                        selected: ctrl.selectedLevel.value == level,
                        onSelected: (_) => ctrl.setLevelFilter(level),
                      ))
                  .toList(),
            )),
            const SizedBox(height: 16),
            const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Wrap(
              spacing: 8,
              children: ['all', 'daily', 'business', 'academic']
                  .map((cat) => ChoiceChip(
                        label: Text(cat),
                        selected: ctrl.selectedCategory.value == cat,
                        onSelected: (_) => ctrl.setCategoryFilter(cat),
                      ))
                  .toList(),
            )),
            const SizedBox(height: 16),
            Obx(() => CheckboxListTile(
              title: const Text('Show only unlearned'),
              value: ctrl.showOnlyUnlearned.value,
              onChanged: (_) => ctrl.toggleShowUnlearned(),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctrl.clearFilters();
              Get.back();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFlashcardDialog(BuildContext context, VocabularyController ctrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Obx(() {
          final word = ctrl.currentFlashcard.value;
          if (word == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No more words!'),
            );
          }

          return GestureDetector(
            onTap: () => ctrl.flipFlashcard(),
            child: Container(
              height: 300,
              width: double.maxFinite,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ctrl.showFlashcardAnswer.value ? word.indonesianMeaning : word.word,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ctrl.showFlashcardAnswer.value ? word.word : 'Tap to reveal',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => ctrl.nextFlashcard(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => ctrl.nextFlashcard(markAsLearned: true),
            child: const Text('I Know This'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _WordCard extends StatelessWidget {
  final VocabularyWord word;
  final VocabularyController ctrl;

  const _WordCard({required this.word, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/vocabulary/detail', arguments: word),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          word.pronunciation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (word.isLearned)
                    Icon(Icons.check_circle, color: Colors.green, size: 32)
                  else
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.blue,
                      onPressed: () => ctrl.markWordAsLearned(word),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                word.indonesianMeaning,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Chip(label: word.level, color: Colors.blue),
                  _Chip(label: word.category, color: Colors.purple),
                  if (word.isLearned)
                    _Chip(
                      label: 'Mastery: ${word.masteryLevel}%',
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
