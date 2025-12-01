import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quiz_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;
  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('conatus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    return await openDatabase(
      path,
      version: 3, // Increased version for admin features
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // user table with password field
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT DEFAULT 'user'
    );
    ''');

    // admin table
    await db.execute('''
    CREATE TABLE admins(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    ''');

    // courses stored locally
    await db.execute('''
    CREATE TABLE courses(
      id INTEGER PRIMARY KEY,
      title TEXT,
      level TEXT,
      progress INTEGER DEFAULT 0,
      description TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    ''');

    // quizzes table - store quiz questions in database
    await db.execute('''
    CREATE TABLE quizzes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      course_id INTEGER,
      question TEXT NOT NULL,
      options TEXT NOT NULL,
      answer_index INTEGER NOT NULL,
      difficulty TEXT DEFAULT 'medium',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE
    );
    ''');

    // quiz progress per course
    await db.execute('''
    CREATE TABLE quiz_progress(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      course_id INTEGER,
      question_index INTEGER,
      correct INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(course_id) REFERENCES courses(id)
    );
    ''');

    // user quiz results
    await db.execute('''
    CREATE TABLE user_quiz_results(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      course_id INTEGER,
      quiz_id INTEGER,
      selected_option INTEGER,
      is_correct INTEGER DEFAULT 0,
      completed_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(course_id) REFERENCES courses(id),
      FOREIGN KEY(quiz_id) REFERENCES quizzes(id)
    );
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // insert sample course
    await db.insert('courses', {
      'id': 1,
      'title': 'Basic Grammar',
      'level': 'Beginner',
      'progress': 0,
      'description': 'Learn the fundamentals of English grammar'
    });

    // insert demo user
    await db.insert('users', {
      'name': 'Sarah',
      'email': 'sarah@conatus.com',
      'password': 'sarah123',
      'role': 'user',
    });

    // insert demo admin
    await db.insert('admins', {
      'name': 'Admin',
      'email': 'admin@conatus.com',
      'password': 'admin123',
    });

    // Insert sample quizzes
    final sampleQuizzes = [
      {
        'course_id': 1,
        'question': 'What is the correct form of the verb "to be" for "I"?',
        'options': '["am","is","are","be"]',
        'answer_index': 0,
        'difficulty': 'easy',
      },
      {
        'course_id': 1,
        'question': 'Which sentence is grammatically correct?',
        'options':
        '["She go to school everyday","She goes to school everyday","She going to school everyday","She gone to school everyday"]',
        'answer_index': 1,
        'difficulty': 'medium',
      },
      {
        'course_id': 1,
        'question': 'Choose the correct article: ___ apple a day keeps the doctor away.',
        'options': '["A","An","The","No article"]',
        'answer_index': 1,
        'difficulty': 'easy',
      },
    ];

    for (var quiz in sampleQuizzes) {
      await db.insert('quizzes', quiz);
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
        await db.execute(
            'UPDATE users SET password = "password123" WHERE password IS NULL');
      } catch (e) {
        print('Error upgrading to version 2: $e');
      }
    }

    if (oldVersion < 3) {
      // Add admin and quiz management tables
      try {
        // Add role to users
        await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');

        // Create admins table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS admins(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
        ''');

        // Create quizzes table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS quizzes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER,
          question TEXT NOT NULL,
          options TEXT NOT NULL,
          answer_index INTEGER NOT NULL,
          difficulty TEXT DEFAULT 'medium',
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE CASCADE
        );
        ''');

        // Create user_quiz_results table
        await db.execute('''
        CREATE TABLE IF NOT EXISTS user_quiz_results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          course_id INTEGER,
          quiz_id INTEGER,
          selected_option INTEGER,
          is_correct INTEGER DEFAULT 0,
          completed_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(id),
          FOREIGN KEY(course_id) REFERENCES courses(id),
          FOREIGN KEY(quiz_id) REFERENCES quizzes(id)
        );
        ''');

        // Add description to courses
        await db.execute(
            'ALTER TABLE courses ADD COLUMN description TEXT DEFAULT ""');

        // Insert default admin if not exists
        var admins = await db.query('admins', limit: 1);
        if (admins.isEmpty) {
          await db.insert('admins', {
            'name': 'Admin',
            'email': 'admin@conatus.com',
            'password': 'admin123',
          });
        }
      } catch (e) {
        print('Error upgrading to version 3: $e');
      }
    }
  }

  // ========== ADMIN METHODS ==========

  Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'admins',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ========== QUIZ CRUD METHODS ==========

  Future<int> insertQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.insert('quizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    final db = await database;
    return await db.query('quizzes', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getQuizzesByCourse(int courseId) async {
    final db = await database;
    return await db.query(
      'quizzes',
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, dynamic>?> getQuizById(int id) async {
    final db = await database;
    final results = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateQuiz(int id, Map<String, dynamic> quiz) async {
    final db = await database;
    quiz['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'quizzes',
      quiz,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQuiz(int id) async {
    final db = await database;
    return await db.delete(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== USER QUIZ RESULTS ==========

  Future<int> insertUserQuizResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('user_quiz_results', result);
  }

  Future<List<Map<String, dynamic>>> getUserQuizResults(int userId) async {
    final db = await database;
    return await db.query(
      'user_quiz_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsersResults() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.name as user_name,
        u.email as user_email,
        c.title as course_title,
        COUNT(uqr.id) as total_questions,
        SUM(uqr.is_correct) as correct_answers,
        MAX(uqr.completed_at) as last_attempt
      FROM users u
      LEFT JOIN user_quiz_results uqr ON u.id = uqr.user_id
      LEFT JOIN courses c ON uqr.course_id = c.id
      GROUP BY u.id, c.id
      ORDER BY last_attempt DESC
    ''');
  }

  // ========== STATISTICS ==========

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final totalUsers = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users')) ??
        0;

    final totalQuizzes = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM quizzes')) ??
        0;

    final totalCourses = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM courses')) ??
        0;

    final totalAttempts = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM user_quiz_results')) ??
        0;

    return {
      'total_users': totalUsers,
      'total_quizzes': totalQuizzes,
      'total_courses': totalCourses,
      'total_attempts': totalAttempts,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> initDB() async {
    await database;
  }
}