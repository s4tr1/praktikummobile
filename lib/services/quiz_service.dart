import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

class QuizService {
  // read from assets/quizzes.json
  Future<List<QuizModel>> fetchQuizzes({String course = 'basic_grammar'}) async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final data = await rootBundle.loadString('assets/quizzes.json');
    final jsonMap = json.decode(data) as Map<String, dynamic>;
    final list = jsonMap[course] as List<dynamic>? ?? [];
    return list.map((e) => QuizModel.fromMap(e as Map<String, dynamic>)).toList();
  }
}
