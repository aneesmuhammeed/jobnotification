import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:jobnoti/core/error/exceptions.dart' as custom_err;
import 'package:jobnoti/features/auth/data/models/user_model.dart';
import 'package:jobnoti/core/services/notification_service.dart';

/// Abstract auth data source.
abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> toggleNotifications(bool enabled);

  Future<UserModel> updateDailyReminder(bool enabled, String timeUtc);
}

/// Supabase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final NotificationService notificationService;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.notificationService,
  });

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const custom_err.AuthException('Registration failed. Please try again.');
      }

      // Get FCM token
      final fcmToken = await notificationService.getFcmToken();

      // Create a profile row in the profiles table
      await supabaseClient.from(AppConstants.profilesTable).insert({
        'id': user.id,
        'full_name': fullName,
        'role': AppConstants.roleUser,
        'fcm_token': fcmToken,
        'notification_enabled': true,
      });

      return UserModel(
        id: user.id,
        email: email,
        fullName: fullName,
        role: AppConstants.roleUser,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw custom_err.AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const custom_err.AuthException('Login failed. Please check your credentials.');
      }

      // Get FCM token and update profile if needed
      final fcmToken = await notificationService.getFcmToken();
      
      if (fcmToken != null) {
        await supabaseClient
            .from(AppConstants.profilesTable)
            .update({'fcm_token': fcmToken})
            .eq('id', user.id);
      }

      // Fetch the user's profile to get their role and full name
      final profileData = await supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson({
        ...profileData,
        'email': email,
      });
    } on AuthException {
      rethrow;
    } catch (e) {
      throw custom_err.AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw custom_err.AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final profileData = await supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson({
        ...profileData,
        'email': user.email ?? '',
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> toggleNotifications(bool enabled) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const custom_err.AuthException('Not authenticated');
      }

      await supabaseClient
          .from(AppConstants.profilesTable)
          .update({'notification_enabled': enabled})
          .eq('id', user.id);

      final profileData = await supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson({
        ...profileData,
        'email': user.email ?? '',
      });
    } catch (e) {
      throw custom_err.AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> updateDailyReminder(bool enabled, String timeUtc) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const custom_err.AuthException('Not authenticated');
      }

      await supabaseClient
          .from(AppConstants.profilesTable)
          .update({
            'daily_reminder_enabled': enabled,
            'reminder_time_utc': timeUtc,
          })
          .eq('id', user.id);

      final profileData = await supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson({
        ...profileData,
        'email': user.email ?? '',
      });
    } catch (e) {
      throw custom_err.AuthException(e.toString());
    }
  }
}
