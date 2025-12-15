import 'dart:convert';
import '../data/db_helper.dart';
import '../models/quiz_model.dart';

class AdminService {
  final DBHelper _db = DBHelper.instance;

  // ========== AUTHENTICATION ==========

  Future<Map<String, dynamic>?> loginAdmin(
      String email, String password) async {
    final admin = await _db.getAdminByEmail(email);
    if (admin != null && admin['password'] == password) {
      return admin;
    }
    return null;
  }

  // ========== QUIZ CRUD ==========

  Future<int> createQuiz({
    required int courseId,
    required String question,
    required List<String> options,
    required int answerIndex,
    String difficulty = 'medium',
  }) async {
    final quiz = {
      'course_id': courseId,
      'question': question,
      'options': jsonEncode(options),
      'answer_index': answerIndex,
      'difficulty': difficulty,
    };
    return await _db.insertQuiz(quiz);
  }

  Future<List<QuizModel>> getAllQuizzes() async {
    final results = await _db.getAllQuizzes();
    return results.map((map) {
      return QuizModel(
        id: map['id'].toString(),
        question: map['question'] as String,
        options: List<String>.from(jsonDecode(map['options'] as String)),
        answerIndex: map['answer_index'] as int,
      );
    }).toList();
  }

  Future<List<QuizModel>> getQuizzesByCourse(int courseId) async {
    final results = await _db.getQuizzesByCourse(courseId);
    return results.map((map) {
      return QuizModel(
        id: map['id'].toString(),
        question: map['question'] as String,
        options: List<String>.from(jsonDecode(map['options'] as String)),
        answerIndex: map['answer_index'] as int,
      );
    }).toList();
  }

  Future<Map<String, dynamic>?> getQuizById(int id) async {
    return await _db.getQuizById(id);
  }

  Future<int> updateQuiz({
    required int id,
    required int courseId,
    required String question,
    required List<String> options,
    required int answerIndex,
    String difficulty = 'medium',
  }) async {
    final quiz = {
      'course_id': courseId,
      'question': question,
      'options': jsonEncode(options),
      'answer_index': answerIndex,
      'difficulty': difficulty,
    };
    return await _db.updateQuiz(id, quiz);
  }

  Future<int> deleteQuiz(int id) async {
    return await _db.deleteQuiz(id);
  }

  // ========== USER RESULTS ==========

  Future<void> saveUserQuizResult({
    required int userId,
    required int courseId,
    required int quizId,
    required int selectedOption,
    required bool isCorrect,
  }) async {
    await _db.insertUserQuizResult({
      'user_id': userId,
      'course_id': courseId,
      'quiz_id': quizId,
      'selected_option': selectedOption,
      'is_correct': isCorrect ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUserResults(int userId) async {
    return await _db.getUserQuizResults(userId);
  }

  Future<List<Map<String, dynamic>>> getAllUsersResults() async {
    return await _db.getAllUsersResults();
  }

  // ========== STATISTICS ==========

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _db.getDashboardStats();
  }

  Future<Map<String, dynamic>> getQuizStatistics(int quizId) async {
    // Get statistics for a specific quiz
    final results = await _db.database;
    final stats = await results.rawQuery('''
      SELECT 
        COUNT(*) as total_attempts,
        SUM(is_correct) as correct_attempts,
        (SUM(is_correct) * 100.0 / COUNT(*)) as success_rate
      FROM user_quiz_results
      WHERE quiz_id = ?
    ''', [quizId]);

    return stats.isNotEmpty
        ? stats.first
        : {
      'total_attempts': 0,
      'correct_attempts': 0,
      'success_rate': 0.0,
    };
  }
}