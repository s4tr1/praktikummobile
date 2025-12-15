class SupabaseConfig {
  // Supabase credentials
  static const String supabaseUrl = 'https://tkjvffotvgdzylacvjvh.supabase.co';
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRranZmZm90dmdkenlsYWN2anZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODM5MTYsImV4cCI6MjA3ODk1OTkxNn0.l4x8XkLCQ3vDu-Q2nSc3CavKV5AVRuNnWEfr9pGAc6s';
  
  // Table names
  static const String usersTable = 'users';
  static const String adminsTable = 'admins';
  static const String coursesTable = 'courses';
  static const String quizzesTable = 'quizzes';
  static const String userQuizResultsTable = 'user_quiz_results';
  static const String quizProgressTable = 'quiz_progress';
  
  // Hive box names
  static const String userBoxName = 'user_box';
  static const String courseBoxName = 'course_box';
  static const String quizBoxName = 'quiz_box';
  static const String settingsBoxName = 'settings_box';
}