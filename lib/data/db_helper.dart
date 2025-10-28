import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

    // create dir if not exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    return await openDatabase(path,
        version: 2, // Increased version for password field
        onCreate: _createDB,
        onUpgrade: _onUpgrade, onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future _createDB(Database db, int version) async {
    // user table with password field
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL
    );
    ''');

    // courses stored locally
    await db.execute('''
    CREATE TABLE courses(
      id INTEGER PRIMARY KEY,
      title TEXT,
      level TEXT,
      progress INTEGER DEFAULT 0
    );
    ''');

    // quiz progress per course
    await db.execute('''
    CREATE TABLE quiz_progress(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      courseId INTEGER,
      questionIndex INTEGER,
      correct INTEGER DEFAULT 0,
      FOREIGN KEY(courseId) REFERENCES courses(id)
    );
    ''');

    // insert sample course
    await db.insert('courses', {
      'id': 1,
      'title': 'Basic Grammar',
      'level': 'Beginner',
      'progress': 0
    });

    // insert demo user
    await db.insert('users', {
      'name': 'Sarah',
      'email': 'sarah@conatus.com',
      'password': 'sarah123',
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add password column if upgrading from version 1
      try {
        await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
        // Update existing users with default password
        await db.execute(
            'UPDATE users SET password = "password123" WHERE password IS NULL');
      } catch (e) {
        print('Error upgrading database: $e');
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> initDB() async {
    await database;
  }
}
