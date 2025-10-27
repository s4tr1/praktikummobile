import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  factory DBHelper() => instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'conatus_academy.db');

    return await openDatabase(
      path,
      version: 2, // ✅ Increment version untuk update schema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 👤 Tabel Users
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // 📚 Tabel Courses
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        level TEXT,
        imagePath TEXT,
        completed INTEGER DEFAULT 0
      )
    ''');

    // 📝 Tabel Quizzes
    await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId INTEGER NOT NULL,
        question TEXT NOT NULL,
        optionA TEXT NOT NULL,
        optionB TEXT NOT NULL,
        optionC TEXT NOT NULL,
        optionD TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    // 📊 Tabel Progress
    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        courseId INTEGER NOT NULL,
        progress REAL DEFAULT 0.0,
        score INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE,
        UNIQUE(userId, courseId)
      )
    ''');

    // 🎯 Tabel Quizzes Taken (untuk tracking kuis yang sudah dikerjakan)
    await db.execute('''
      CREATE TABLE quizzes_taken(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        courseId INTEGER NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        takenAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    // 🌱 Insert Data Awal (Seeding)
    await _seedData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop all tables and recreate
      await db.execute('DROP TABLE IF EXISTS courses');
      await db.execute('DROP TABLE IF EXISTS quizzes');
      await db.execute('DROP TABLE IF EXISTS progress');
      await db.execute('DROP TABLE IF EXISTS quizzes_taken');

      // Recreate tables
      await db.execute('''
        CREATE TABLE courses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          level TEXT,
          imagePath TEXT,
          completed INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE quizzes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          courseId INTEGER NOT NULL,
          question TEXT NOT NULL,
          optionA TEXT NOT NULL,
          optionB TEXT NOT NULL,
          optionC TEXT NOT NULL,
          optionD TEXT NOT NULL,
          correctAnswer TEXT NOT NULL,
          FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE progress(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          courseId INTEGER NOT NULL,
          progress REAL DEFAULT 0.0,
          score INTEGER,
          FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE,
          UNIQUE(userId, courseId)
        )
      ''');

      await db.execute('''
        CREATE TABLE quizzes_taken(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          courseId INTEGER NOT NULL,
          score INTEGER NOT NULL,
          totalQuestions INTEGER NOT NULL,
          takenAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE
        )
      ''');

      await _seedData(db);
    }
  }

  Future _seedData(Database db) async {
    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
    });

    // Insert default regular user
    await db.insert('users', {
      'username': 'user',
      'password': 'user123',
      'role': 'user',
    });

    // Insert sample courses
    await db.insert('courses', {
      'title': 'Basic English A1',
      'description':
          'Learn the fundamentals of English language for absolute beginners',
      'level': 'A1',
      'imagePath': '',
      'completed': 0,
    });

    await db.insert('courses', {
      'title': 'Elementary English A2',
      'description': 'Build your English skills with elementary level content',
      'level': 'A2',
      'imagePath': '',
      'completed': 0,
    });

    await db.insert('courses', {
      'title': 'Intermediate English B1',
      'description':
          'Take your English to the next level with intermediate topics',
      'level': 'B1',
      'imagePath': '',
      'completed': 0,
    });

    await db.insert('courses', {
      'title': 'Upper Intermediate B2',
      'description': 'Master complex English grammar and vocabulary',
      'level': 'B2',
      'imagePath': '',
      'completed': 0,
    });

    await db.insert('courses', {
      'title': 'Advanced English C1',
      'description': 'Achieve fluency with advanced English concepts',
      'level': 'C1',
      'imagePath': '',
      'completed': 0,
    });

    // Insert sample quizzes for course 1 (Basic English A1)
    await db.insert('quizzes', {
      'courseId': 1,
      'question': 'What is the correct greeting in the morning?',
      'optionA': 'Good night',
      'optionB': 'Good morning',
      'optionC': 'Good afternoon',
      'optionD': 'Good evening',
      'correctAnswer': 'B',
    });

    await db.insert('quizzes', {
      'courseId': 1,
      'question': 'How do you say "terima kasih" in English?',
      'optionA': 'Please',
      'optionB': 'Sorry',
      'optionC': 'Thank you',
      'optionD': 'Welcome',
      'correctAnswer': 'C',
    });

    await db.insert('quizzes', {
      'courseId': 1,
      'question': 'What is the plural of "cat"?',
      'optionA': 'Cats',
      'optionB': 'Cates',
      'optionC': 'Cat',
      'optionD': 'Catses',
      'correctAnswer': 'A',
    });

    // Insert sample quizzes for course 2 (Elementary English A2)
    await db.insert('quizzes', {
      'courseId': 2,
      'question': 'Which sentence is correct?',
      'optionA': 'She go to school',
      'optionB': 'She goes to school',
      'optionC': 'She going to school',
      'optionD': 'She goed to school',
      'correctAnswer': 'B',
    });

    await db.insert('quizzes', {
      'courseId': 2,
      'question': 'What is the past tense of "run"?',
      'optionA': 'Runned',
      'optionB': 'Running',
      'optionC': 'Ran',
      'optionD': 'Runs',
      'correctAnswer': 'C',
    });

    print("✅ Database seeded with sample data");
  }

  // Helper method to reset database (useful for development)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'conatus_academy.db');
    await deleteDatabase(path);
    _database = null;
    await database; // Reinitialize
  }
}
