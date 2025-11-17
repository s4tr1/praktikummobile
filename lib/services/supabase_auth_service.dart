import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========== USER AUTHENTICATION ==========

  /// Register new user with Supabase Auth
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Store name in user metadata
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // 2. Create user profile in users table
      final userProfile = {
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(SupabaseConfig.usersTable)
          .insert(userProfile);

      return UserModel.fromJson({
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login user with email and password
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid credentials');
      }

      // 2. Get user profile from users table
      final userProfileResponse = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      // 3. Update last login
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', authResponse.user!.id);

      return UserModel.fromJson(userProfileResponse);
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Get current user
  User? getCurrentAuthUser() {
    return _supabase.auth.currentUser;
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ========== ADMIN AUTHENTICATION ==========

  /// Login admin (custom implementation with admins table)
  Future<Map<String, dynamic>?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      // Query admins table directly
      final response = await _supabase
          .from(SupabaseConfig.adminsTable)
          .select()
          .eq('email', email)
          .eq('password', password) // In production, use proper password hashing!
          .maybeSingle();

      if (response == null) {
        throw Exception('Invalid admin credentials');
      }

      return response;
    } catch (e) {
      throw Exception('Admin login failed: $e');
    }
  }

  /// Create admin (for initial setup)
  Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _supabase.from(SupabaseConfig.adminsTable).insert({
        'email': email,
        'password': password, // In production, hash this!
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create admin: $e');
    }
  }

  // ========== PASSWORD RESET ==========

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Password update failed: ${e.message}');
    }
  }
}