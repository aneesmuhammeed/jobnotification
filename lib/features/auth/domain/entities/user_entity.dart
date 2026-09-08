import 'package:equatable/equatable.dart';

/// User entity — domain layer representation of a user.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool notificationEnabled;
  final bool dailyReminderEnabled;
  final String reminderTimeUtc;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.notificationEnabled = true,
    this.dailyReminderEnabled = true,
    this.reminderTimeUtc = '12:30:00',
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        notificationEnabled,
        dailyReminderEnabled,
        reminderTimeUtc,
      ];
}
