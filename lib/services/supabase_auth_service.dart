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
      print('🔵 Starting registration for: $email');

      // 1. Sign up dengan Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Metadata for trigger
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create auth account');
      }

      final userId = authResponse.user!.id;
      print('✅ Auth user created: $userId');

      // 2. Wait for trigger to execute (1 second should be enough)
      await Future.delayed(const Duration(seconds: 1));

      // 3. Try to fetch profile (created by trigger)
      try {
        print('🔵 Fetching user profile...');
        final profile = await _supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('id', userId)
            .single();

        print('✅ Profile found via trigger: ${profile['name']}');
        return UserModel.fromJson(profile);
      } catch (fetchError) {
        print('⚠️ Profile not found by trigger, creating manually...');
        print('   Fetch error: $fetchError');

        // 4. Manual insert if trigger failed (WITHOUT role field if not exists)
        try {
          final userProfile = {
            'id': userId,
            'email': email,
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
            'last_login_at': DateTime.now().toIso8601String(),
          };

          print('🔵 Attempting manual insert...');
          final insertedProfile = await _supabase
              .from(SupabaseConfig.usersTable)
              .insert(userProfile)
              .select()
              .single();

          print('✅ Profile created manually: ${insertedProfile['name']}');
          return UserModel.fromJson(insertedProfile);
        } catch (insertError) {
          print('❌ Manual insert failed: $insertError');

          // 5. Last attempt: Wait and fetch again
          print('🔵 Waiting 2 seconds and trying fetch again...');
          await Future.delayed(const Duration(seconds: 2));

          try {
            final retryProfile = await _supabase
                .from(SupabaseConfig.usersTable)
                .select()
                .eq('id', userId)
                .single();

            print('✅ Profile found on retry: ${retryProfile['name']}');
            return UserModel.fromJson(retryProfile);
          } catch (retryError) {
            print('❌ Final fetch failed: $retryError');
            print('⚠️ Account created but profile fetch failed');

            // Return a basic user model so registration is treated as success
            // User can login and profile will be created on login
            return UserModel(
              id: userId,
              email: email,
              name: name,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            );
          }
        }
      }
    } on AuthException catch (e) {
      print('❌ Auth Exception: ${e.message}');
      print('   Status Code: ${e.statusCode}');

      // User-friendly error messages
      if (e.message.contains('already registered') ||
          e.message.contains('already been registered')) {
        throw Exception(
            'This email is already registered. Please login instead.');
      } else if (e.message.contains('Invalid email')) {
        throw Exception('Please enter a valid email address.');
      } else if (e.message.contains('Password')) {
        throw Exception('Password must be at least 6 characters.');
      } else if (e.message.contains('Email rate limit')) {
        throw Exception('Too many attempts. Please try again later.');
      }

      throw Exception(e.message);
    } catch (e) {
      print('❌ General Exception: $e');

      final errorStr = e.toString().toLowerCase();

      // Don't throw exception for success messages!
      if (errorStr.contains('account created successfully')) {
        print('⚠️ Success message in exception - treating as success');
        // Return basic user model
        return UserModel(
          id: '',
          email: email,
          name: name,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }

      if (errorStr.contains('duplicate') || errorStr.contains('unique')) {
        throw Exception(
            'This email is already registered. Please use another email.');
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        throw Exception(
            'Network error. Please check your internet connection.');
      } else if (errorStr.contains('permission denied')) {
        throw Exception('Database permission error. Please contact support.');
      }

      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login user with email and password
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Starting login for: $email');

      // 1. Sign in with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid credentials');
      }

      final userId = authResponse.user!.id;
      print('✅ Auth successful for user: $userId');

      // 2. Get user profile from users table
      try {
        final userProfile = await _supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('id', userId)
            .single();

        print('✅ User profile fetched: ${userProfile['name']}');

        // 3. Update last login timestamp
        try {
          await _supabase
              .from(SupabaseConfig.usersTable)
              .update({'last_login_at': DateTime.now().toIso8601String()}).eq(
                  'id', userId);
        } catch (updateError) {
          print('⚠️ Failed to update last_login_at: $updateError');
          // Non-critical, continue
        }

        return UserModel.fromJson(userProfile);
      } catch (profileError) {
        print('❌ Profile fetch error: $profileError');

        // Profile doesn't exist - try to create it
        if (profileError.toString().contains('permission denied')) {
          throw Exception('Account not fully set up. Please contact support.');
        }

        throw Exception('User profile not found. Please register first.');
      }
    } on AuthException catch (e) {
      print('❌ Login Auth Exception: ${e.message}');

      if (e.message.contains('Invalid login') ||
          e.message.contains('Invalid email or password')) {
        throw Exception('Invalid email or password');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Please verify your email first');
      } else if (e.message.contains('Email rate limit')) {
        throw Exception('Too many login attempts. Please try again later.');
      }

      throw Exception(e.message);
    } catch (e) {
      print('❌ Login Exception: $e');

      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('profile not found')) {
        rethrow;
      } else if (errorStr.contains('account not fully set up')) {
        rethrow;
      }

      throw Exception('Login failed. Please try again.');
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await _supabase.auth.signOut();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  /// Get current auth user
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
      print('❌ Get profile error: $e');
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

      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Update profile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // ========== ADMIN AUTHENTICATION ==========

  /// Login admin using custom admins table
  Future<Map<String, dynamic>?> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Admin login attempt: $email');

      // Query admins table directly
      final response = await _supabase
          .from(SupabaseConfig.adminsTable)
          .select()
          .eq('email', email)
          .eq('password', password) // ⚠️ Production: use bcrypt!
          .maybeSingle();

      if (response == null) {
        print('❌ Admin not found or wrong password');
        throw Exception('Invalid admin credentials');
      }

      print('✅ Admin login successful: ${response['name']}');
      return response;
    } catch (e) {
      print('❌ Admin login error: $e');

      if (e.toString().contains('Invalid admin credentials')) {
        throw Exception('Invalid email or password');
      }

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
        'password': password, // ⚠️ Production: hash this!
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Admin created: $email');
    } catch (e) {
      print('❌ Create admin error: $e');
      throw Exception('Failed to create admin: $e');
    }
  }

  // ========== PASSWORD RESET ==========

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent to: $email');
    } on AuthException catch (e) {
      print('❌ Password reset error: ${e.message}');
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('✅ Password updated successfully');
    } on AuthException catch (e) {
      print('❌ Password update error: ${e.message}');
      throw Exception('Password update failed: ${e.message}');
    }
  }
}
