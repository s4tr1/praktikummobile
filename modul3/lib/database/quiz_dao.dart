import 'db_helper.dart';
import '../models/quiz_model.dart';

class QuizDAO {
  final dbHelper = DBHelper.instance;

  Future<int> insertQuiz(QuizModel q) async {
    final db = await dbHelper.database;
    return await db.insert('quizzes', q.toMap());
  }

  Future<List<QuizModel>> getQuizzesByCourse(int courseId) async {
    final db = await dbHelper.database;
    final res = await db.query('quizzes', where: 'courseId = ?', whereArgs: [courseId]);
    return res.map((m) => QuizModel.fromMap(m)).toList();
  }

  Future<int> deleteQuiz(int id) async {
    final db = await dbHelper.database;
    return await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }
}
