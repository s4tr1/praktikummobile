import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../config/supabase_config.dart';

class SupabaseDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========== COURSE OPERATIONS ==========

  /// Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.coursesTable)
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  /// Get course by ID
  Future<CourseModel?> getCourseById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.coursesTable)
          .select()
          .eq('id', id)
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  /// Create new course (Admin only)
  Future<CourseModel> createCourse({
    required String title,
    required String level,
    String? description,
  }) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.coursesTable)
          .insert({
            'title': title,
            'level': level,
            'progress': 0,
            'description': description,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return CourseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

  /// Update course progress
  Future<void> updateCourseProgress(int courseId, int progress) async {
    try {
      await _supabase
          .from(SupabaseConfig.coursesTable)
          .update({'progress': progress}).eq('id', courseId);
    } catch (e) {
      throw Exception('Failed to update course progress: $e');
    }
  }

  /// Update course (Admin only)
  Future<void> updateCourse({
    required int id,
    String? title,
    String? level,
    String? description,
    int? progress,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (level != null) updates['level'] = level;
      if (description != null) updates['description'] = description;
      if (progress != null) updates['progress'] = progress;

      await _supabase
          .from(SupabaseConfig.coursesTable)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  /// Delete course (Admin only)
  Future<void> deleteCourse(int id) async {
    try {
      await _supabase.from(SupabaseConfig.coursesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // ========== QUIZ OPERATIONS ==========

  /// Get all quizzes
  Future<List<QuizModel>> getAllQuizzes() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.quizzesTable)
          .select()
          .order('id', ascending: false);

      return (response as List)
          .map((json) => QuizModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  /// Get quizzes by course
  Future<List<QuizModel>> getQuizzesByCourse(int courseId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.quizzesTable)
          .select()
          .eq('course_id', courseId)
          .order('id', ascending: true);

      return (response as List)
          .map((json) => QuizModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  /// Get quiz by ID
  Future<QuizModel?> getQuizById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.quizzesTable)
          .select()
          .eq('id', id)
          .single();

      return QuizModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch quiz: $e');
    }
  }

  /// Create new quiz (Admin only)
  Future<QuizModel> createQuiz({
    required int courseId,
    required String question,
    required List<String> options,
    required int answerIndex,
    String difficulty = 'medium',
  }) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.quizzesTable)
          .insert({
            'course_id': courseId,
            'question': question,
            'options': options,
            'answer_index': answerIndex,
            'difficulty': difficulty,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return QuizModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  /// Update quiz (Admin only)
  Future<void> updateQuiz({
    required int id,
    int? courseId,
    String? question,
    List<String>? options,
    int? answerIndex,
    String? difficulty,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (courseId != null) updates['course_id'] = courseId;
      if (question != null) updates['question'] = question;
      if (options != null) updates['options'] = options;
      if (answerIndex != null) updates['answer_index'] = answerIndex;
      if (difficulty != null) updates['difficulty'] = difficulty;

      await _supabase
          .from(SupabaseConfig.quizzesTable)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  /// Delete quiz (Admin only)
  Future<void> deleteQuiz(int id) async {
    try {
      await _supabase.from(SupabaseConfig.quizzesTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // ========== USER QUIZ RESULTS ==========

  /// Save user quiz result
  Future<void> saveUserQuizResult({
    required String userId,
    required int courseId,
    required int quizId,
    required int selectedOption,
    required bool isCorrect,
  }) async {
    try {
      await _supabase.from(SupabaseConfig.userQuizResultsTable).insert({
        'user_id': userId,
        'course_id': courseId,
        'quiz_id': quizId,
        'selected_option': selectedOption,
        'is_correct': isCorrect,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save quiz result: $e');
    }
  }

  /// Get user quiz results
  Future<List<Map<String, dynamic>>> getUserQuizResults(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.userQuizResultsTable)
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch user results: $e');
    }
  }

  /// Get all users results (Admin only)
  Future<List<Map<String, dynamic>>> getAllUsersResults() async {
    try {
      final response = await _supabase.rpc('get_all_users_results');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to simple query if RPC doesn't exist
      try {
        final response = await _supabase
            .from(SupabaseConfig.userQuizResultsTable)
            .select('*, users(name, email), courses(title)')
            .order('completed_at', ascending: false);

        return List<Map<String, dynamic>>.from(response);
      } catch (e2) {
        throw Exception('Failed to fetch all results: $e2');
      }
    }
  }

  // ========== DASHBOARD STATISTICS ==========

  /// Get dashboard statistics (Admin only)
  /// Using manual count method (compatible with all versions)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Fetch and count manually - Most compatible method
      final usersData =
          await _supabase.from(SupabaseConfig.usersTable).select('id');

      final quizzesData =
          await _supabase.from(SupabaseConfig.quizzesTable).select('id');

      final coursesData =
          await _supabase.from(SupabaseConfig.coursesTable).select('id');

      final attemptsData = await _supabase
          .from(SupabaseConfig.userQuizResultsTable)
          .select('id');

      return {
        'total_users': (usersData as List).length,
        'total_quizzes': (quizzesData as List).length,
        'total_courses': (coursesData as List).length,
        'total_attempts': (attemptsData as List).length,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}
