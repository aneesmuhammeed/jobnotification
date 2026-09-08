import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';

/// User data model — maps between Supabase JSON and domain entity.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.notificationEnabled,
    super.dailyReminderEnabled,
    super.reminderTimeUtc,
  });

  /// Create a UserModel from a Supabase profiles row + auth user data.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String? ?? 'user',
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      dailyReminderEnabled: json['daily_reminder_enabled'] as bool? ?? true,
      reminderTimeUtc: json['reminder_time_utc'] as String? ?? '12:30:00',
    );
  }

  /// Convert to a JSON map for Supabase insert/update.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'notification_enabled': notificationEnabled,
      'daily_reminder_enabled': dailyReminderEnabled,
      'reminder_time_utc': reminderTimeUtc,
    };
  }
}
