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
        version: 1,
        onCreate: _createDB,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        });
  }

  Future _createDB(Database db, int version) async {
    // user table
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT
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
    await db.insert('courses', {'id': 1, 'title': 'Basic Grammar', 'level': 'Beginner', 'progress': 0});
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> initDB() async {
    await database;
  }
}
