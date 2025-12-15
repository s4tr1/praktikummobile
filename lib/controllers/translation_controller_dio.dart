import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/translation_service_dio.dart';

class TranslatorControllerDio extends GetxController {
  final TranslationServiceDio _service = TranslationServiceDio();

  var sourceText = ''.obs;
  var translatedText = ''.obs;
  var isTranslating = false.obs;
  var errorMessage = ''.obs;
  var sourceLanguage = 'en'.obs;
  var targetLanguage = 'id'.obs;
  var supportedLanguages = <String, String>{}.obs;

  final sourceTextController = TextEditingController();
  final translatedTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSupportedLanguages();
  }

  @override
  void onClose() {
    sourceTextController.dispose();
    translatedTextController.dispose();
    _service.cancelRequests();
    super.onClose();
  }

  Future<void> _loadSupportedLanguages() async {
    try {
      final languages = await _service.getSupportedLanguages();
      supportedLanguages.assignAll(languages);
    } catch (e) {
      print('Error loading languages: $e');
    }
  }

  Future<void> translate() async {
    if (sourceText.value.isEmpty) {
      errorMessage.value = 'Masukkan teks untuk diterjemahkan';
      return;
    }

    isTranslating.value = true;
    errorMessage.value = '';

    try {
      final result = await _service.translate(
        text: sourceText.value,
        targetLanguage: targetLanguage.value,
        sourceLanguage: sourceLanguage.value,
      );
      translatedText.value = result;
      translatedTextController.text = result;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      translatedText.value = '';
    } finally {
      isTranslating.value = false;
    }
  }

  void swapLanguages() {
    final temp = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    targetLanguage.value = temp;

    // Swap text juga
    final tempText = sourceText.value;
    sourceText.value = translatedText.value;
    translatedText.value = tempText;

    sourceTextController.text = sourceText.value;
    translatedTextController.text = translatedText.value;
  }

  void copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Get.snackbar(
        'Berhasil',
        'Teks disalin ke clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void clearAll() {
    sourceText.value = '';
    translatedText.value = '';
    sourceTextController.clear();
    translatedTextController.clear();
    errorMessage.value = '';
  }

  void updateSourceText(String text) {
    sourceText.value = text;
  }

  void setSourceLanguage(String lang) {
    sourceLanguage.value = lang;
  }

  void setTargetLanguage(String lang) {
    targetLanguage.value = lang;
  }
}
