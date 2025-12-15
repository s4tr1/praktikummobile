import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  // GRATIS! UNLIMITED! TANPA API KEY!
  // Menggunakan Free Translate API (https://ftapi.pythonanywhere.com/)
  static const String apiUrl = 'https://ftapi.pythonanywhere.com/translate';

  /// Terjemahkan teks ke bahasa target
  /// [text] - teks yang akan diterjemahkan
  /// [targetLanguage] - kode bahasa ('en', 'id', 'es', 'fr', dll)
  /// [sourceLanguage] - deteksi otomatis ('auto') atau spesifik ('en')
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    if (text.isEmpty) {
      throw Exception('Text tidak boleh kosong');
    }

    try {
      // Build query parameters
      final params = {
        'text': text,
        'sl': sourceLanguage,
        'dl': targetLanguage,
      };

      final uri = Uri.parse(apiUrl).replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw Exception('Request timeout - cek koneksi internet'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('destination-text')) {
          return data['destination-text'] ?? text;
        }

        throw Exception('Format response tidak valid');
      } else if (response.statusCode == 400) {
        throw Exception('Bad Request - Language code salah?');
      } else if (response.statusCode == 429) {
        throw Exception('Terlalu banyak request - tunggu sebentar');
      } else {
        throw Exception('Translation gagal: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Terjemahkan multiple teks sekaligus
  Future<List<String>> translateMultiple({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    final translatedList = <String>[];

    for (final text in texts) {
      final translated = await translate(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      translatedList.add(translated);
    }

    return translatedList;
  }

  /// Get supported languages
  Future<Map<String, String>> getSupportedLanguages() async {
    return {
      'en': 'English',
      'id': 'Indonesian',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'zh': 'Chinese',
      'ko': 'Korean',
      'it': 'Italian',
      'nl': 'Dutch',
      'pl': 'Polish',
      'tr': 'Turkish',
    };
  }
}
