import 'package:dio/dio.dart';

class TranslationServiceDio {
  // GRATIS! UNLIMITED! TANPA API KEY!
  // Menggunakan Free Translate API (https://ftapi.pythonanywhere.com/)
  static const String apiUrl = 'https://ftapi.pythonanywhere.com/translate';

  final Dio _dio;

  TranslationServiceDio()
      : _dio = Dio(BaseOptions(
          baseUrl: apiUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
          },
        )) {
    // Add interceptors for logging (optional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

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
      final queryParameters = {
        'text': text,
        'sl': sourceLanguage,
        'dl': targetLanguage,
      };

      final response = await _dio.get(
        '',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data;

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
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Request timeout - cek koneksi internet');
        case DioExceptionType.connectionError:
          throw Exception('Koneksi internet bermasalah');
        case DioExceptionType.badResponse:
          throw Exception('Server error: ${e.response?.statusCode}');
        default:
          throw Exception('Translation error: ${e.message}');
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

  /// Terjemahkan multiple teks secara paralel (lebih cepat)
  Future<List<String>> translateMultipleParallel({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    try {
      final futures = texts.map((text) => translate(
            text: text,
            targetLanguage: targetLanguage,
            sourceLanguage: sourceLanguage,
          ));

      return await Future.wait(futures);
    } catch (e) {
      rethrow;
    }
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
      'ar': 'Arabic',
      'vi': 'Vietnamese',
      'th': 'Thai',
    };
  }

  /// Cancel ongoing requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}
