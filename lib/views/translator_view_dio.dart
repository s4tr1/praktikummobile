import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/translation_controller_dio.dart';

class TranslatorViewDio extends StatelessWidget {
  const TranslatorViewDio({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(TranslatorControllerDio());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Translator',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Language Selection Row
                Obx(() {
                  return Row(
                    children: [
                      // Source Language
                      Expanded(
                        child: _LanguageDropdown(
                          label: 'From',
                          currentLanguage: ctrl.sourceLanguage.value,
                          onChanged: ctrl.setSourceLanguage,
                          languages: ctrl.supportedLanguages,
                        ),
                      ),
                      // Swap Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: ctrl.swapLanguages,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.swap_horiz,
                                  color: Colors.indigo[700],
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Target Language
                      Expanded(
                        child: _LanguageDropdown(
                          label: 'To',
                          currentLanguage: ctrl.targetLanguage.value,
                          onChanged: ctrl.setTargetLanguage,
                          languages: ctrl.supportedLanguages,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Source Text Input
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Input Field
                      TextField(
                        controller: ctrl.sourceTextController,
                        onChanged: ctrl.updateSourceText,
                        maxLines: 6,
                        minLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Masukkan teks untuk diterjemahkan',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      // Character Count & Clear Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              return Text(
                                '${ctrl.sourceText.value.length}/5000',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              );
                            }),
                            Obx(() {
                              return ctrl.sourceText.value.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        ctrl.clearAll();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.grey[500],
                                        size: 20,
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Translate Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: ctrl.sourceText.value.isEmpty
                          ? null
                          : (ctrl.isTranslating.value ? null : ctrl.translate),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.indigo,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: ctrl.isTranslating.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Translate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Error Message
                Obx(() {
                  if (ctrl.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ctrl.errorMessage.value,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),

                // Translated Text Output
                Obx(() {
                  if (ctrl.translatedText.value.isNotEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.indigo[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.indigo[50],
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[100],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.indigo[700], size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Translation Result',
                                  style: TextStyle(
                                    color: Colors.indigo[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Translated Text
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              ctrl.translatedText.value,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                          // Copy Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ctrl.copyToClipboard(
                                        ctrl.translatedText.value);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.copy,
                                          color: Colors.indigo[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Copy',
                                          style: TextStyle(
                                            color: Colors.indigo[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Language Dropdown Widget
class _LanguageDropdown extends StatelessWidget {
  final String label;
  final String currentLanguage;
  final Function(String) onChanged;
  final Map<String, String> languages;

  const _LanguageDropdown({
    required this.label,
    required this.currentLanguage,
    required this.onChanged,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: currentLanguage,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          underline: Container(
            height: 1,
            color: Colors.grey[300],
          ),
          items: languages.entries
              .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
