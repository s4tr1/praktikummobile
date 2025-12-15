import 'dart:convert';
import '../data/db_helper.dart';
import '../services/supabase_data_service.dart';
import '../services/supabase_auth_service.dart';

/// Service untuk migrasi data dari SQLite ke Supabase
/// PERINGATAN: Jalankan sekali saja saat setup awal!
class MigrationService {
  final DBHelper _sqliteDb = DBHelper.instance;
  final SupabaseDataService _supabaseData = SupabaseDataService();
  final SupabaseAuthService _supabaseAuth = SupabaseAuthService();

  /// Status migrasi
  Map<String, dynamic> migrationStatus = {
    'users': {'migrated': 0, 'failed': 0},
    'courses': {'migrated': 0, 'failed': 0},
    'quizzes': {'migrated': 0, 'failed': 0},
  };

  /// Main migration function
  Future<Map<String, dynamic>> migrateAllData() async {
    print('🚀 Starting migration from SQLite to Supabase...\n');

    try {
      // 1. Migrate Courses (independent table)
      await migrateCourses();

      // 2. Migrate Quizzes (depends on courses)
      await migrateQuizzes();

      // 3. Migrate Users (Note: This creates Supabase Auth accounts)
      await migrateUsers();

      print('\n✅ Migration completed!');
      print('📊 Summary:');
      print('   Users: ${migrationStatus['users']['migrated']} migrated, ${migrationStatus['users']['failed']} failed');
      print('   Courses: ${migrationStatus['courses']['migrated']} migrated, ${migrationStatus['courses']['failed']} failed');
      print('   Quizzes: ${migrationStatus['quizzes']['migrated']} migrated, ${migrationStatus['quizzes']['failed']} failed');

      return migrationStatus;
    } catch (e) {
      print('❌ Migration failed: $e');
      return {'error': e.toString()};
    }
  }

  /// Migrate courses from SQLite to Supabase
  Future<void> migrateCourses() async {
    print('📚 Migrating courses...');

    try {
      final db = await _sqliteDb.database;
      final courses = await db.query('courses');

      for (var course in courses) {
        try {
          await _supabaseData.createCourse(
            title: course['title'] as String,
            level: course['level'] as String,
            description: course['description'] as String?,
          );

          migrationStatus['courses']['migrated']++;
          print('  ✓ Course: ${course['title']}');
        } catch (e) {
          migrationStatus['courses']['failed']++;
          print('  ✗ Failed: ${course['title']} - $e');
        }
      }
    } catch (e) {
      print('  ❌ Error migrating courses: $e');
    }
  }

  /// Migrate quizzes from SQLite to Supabase
  Future<void> migrateQuizzes() async {
    print('\n🎯 Migrating quizzes...');

    try {
      final db = await _sqliteDb.database;
      final quizzes = await db.query('quizzes');

      for (var quiz in quizzes) {
        try {
          // Parse options from JSON string
          List<String> options;
          final optionsRaw = quiz['options'];
          
          if (optionsRaw is String) {
            options = List<String>.from(jsonDecode(optionsRaw));
          } else if (optionsRaw is List) {
            options = List<String>.from(optionsRaw);
          } else {
            throw Exception('Invalid options format');
          }

          await _supabaseData.createQuiz(
            courseId: quiz['course_id'] as int,
            question: quiz['question'] as String,
            options: options,
            answerIndex: quiz['answer_index'] as int,
            difficulty: quiz['difficulty'] as String? ?? 'medium',
          );

          migrationStatus['quizzes']['migrated']++;
          print('  ✓ Quiz: ${quiz['question']?.toString().substring(0, 50)}...');
        } catch (e) {
          migrationStatus['quizzes']['failed']++;
          print('  ✗ Failed: ${quiz['id']} - $e');
        }
      }
    } catch (e) {
      print('  ❌ Error migrating quizzes: $e');
    }
  }

  /// Migrate users from SQLite to Supabase
  /// PERINGATAN: Ini akan membuat akun Supabase Auth untuk setiap user
  /// Password akan di-set ke default: "password123"
  Future<void> migrateUsers() async {
    print('\n👥 Migrating users...');
    print('⚠️  NOTE: Default password "password123" will be set for all users');
    print('⚠️  Users need to reset their password via email');

    try {
      final db = await _sqliteDb.database;
      final users = await db.query('users');

      for (var user in users) {
        try {
          // Skip if user already exists in Supabase
          final email = user['email'] as String;
          final name = user['name'] as String;
          
          // Try to register user
          // Password from SQLite won't work with Supabase Auth
          // So we use a default password
          await _supabaseAuth.registerUser(
            email: email,
            password: 'password123', // Default password
            name: name,
          );

          migrationStatus['users']['migrated']++;
          print('  ✓ User: $email (password reset required)');
        } catch (e) {
          // User might already exist
          if (e.toString().contains('already registered') ||
              e.toString().contains('already exists')) {
            print('  ℹ User already exists: ${user['email']}');
            migrationStatus['users']['migrated']++;
          } else {
            migrationStatus['users']['failed']++;
            print('  ✗ Failed: ${user['email']} - $e');
          }
        }
      }

      print('\n⚠️  IMPORTANT: All migrated users must reset their password!');
      print('   Default password: password123');
    } catch (e) {
      print('  ❌ Error migrating users: $e');
    }
  }

  /// Migrate specific user quiz results
  /// Run this after users are migrated
  Future<void> migrateUserQuizResults() async {
    print('\n📊 Migrating user quiz results...');
    print('⚠️  This requires users to be already migrated to Supabase');

    try {
      final db = await _sqliteDb.database;
      final results = await db.query('user_quiz_results');

      int migrated = 0;
      int failed = 0;

      for (var result in results) {
        try {
          // Note: You need to map old user IDs to new Supabase UUIDs
          // This is complex and might need manual mapping
          
          print('  ⚠️  Result migration needs user ID mapping');
          print('     Old user_id: ${result['user_id']}');
          print('     You need to implement ID mapping logic');
          
          failed++;
        } catch (e) {
          failed++;
          print('  ✗ Failed: ${result['id']} - $e');
        }
      }

      print('  📊 Results: $migrated migrated, $failed skipped/failed');
    } catch (e) {
      print('  ❌ Error migrating results: $e');
    }
  }

  /// Check if migration is needed
  Future<bool> needsMigration() async {
    try {
      final db = await _sqliteDb.database;
      
      // Check if SQLite has data
      final usersCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final coursesCount = await db.rawQuery('SELECT COUNT(*) as count FROM courses');
      final quizzesCount = await db.rawQuery('SELECT COUNT(*) as count FROM quizzes');

      final totalRecords = (usersCount.first['count'] as int? ?? 0) +
          (coursesCount.first['count'] as int? ?? 0) +
          (quizzesCount.first['count'] as int? ?? 0);

      return totalRecords > 0;
    } catch (e) {
      print('Error checking migration need: $e');
      return false;
    }
  }

  /// Reset migration status
  void resetStatus() {
    migrationStatus = {
      'users': {'migrated': 0, 'failed': 0},
      'courses': {'migrated': 0, 'failed': 0},
      'quizzes': {'migrated': 0, 'failed': 0},
    };
  }
}

// Example usage in a debug screen:
/*
class MigrationScreen extends StatelessWidget {
  final MigrationService _migrationService = MigrationService();

  Future<void> _startMigration() async {
    final needsMigration = await _migrationService.needsMigration();
    
    if (!needsMigration) {
      Get.snackbar('Info', 'No data to migrate');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Confirm Migration'),
        content: Text('This will migrate all data from SQLite to Supabase. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              Get.dialog(
                Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final result = await _migrationService.migrateAllData();
              
              Get.back(); // Close loading
              
              Get.dialog(
                AlertDialog(
                  title: Text('Migration Complete'),
                  content: Text(result.toString()),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Migrate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Migration')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startMigration,
          child: Text('Start Migration'),
        ),
      ),
    );
  }
}
*/