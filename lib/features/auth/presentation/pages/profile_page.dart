import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/secondary_button.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/pages/admin_dashboard_page.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/core/di/injection_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Helper to convert a local TimeOfDay to UTC TimeOfDay
  TimeOfDay _localToUtc(TimeOfDay localTime) {
    final now = DateTime.now();
    final localDateTime = DateTime(now.year, now.month, now.day, localTime.hour, localTime.minute);
    final utcDateTime = localDateTime.toUtc();
    return TimeOfDay(hour: utcDateTime.hour, minute: utcDateTime.minute);
  }

  // Helper to convert a UTC 'HH:mm:ss' string from backend to local TimeOfDay
  TimeOfDay _utcStringToLocalTime(String utcTimeStr) {
    final parts = utcTimeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 12;
      final minute = int.tryParse(parts[1]) ?? 30;
      final now = DateTime.now();
      final utcDateTime = DateTime.utc(now.year, now.month, now.day, hour, minute);
      final localDateTime = utcDateTime.toLocal();
      return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
    }
    return const TimeOfDay(hour: 18, minute: 0);
  }

  // Helper to format TimeOfDay to 'HH:mm:ss' string
  String _timeOfDayToUtcString(TimeOfDay utcTime) {
    final h = utcTime.hour.toString().padLeft(2, '0');
    final m = utcTime.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _toggleReminder(bool value, String currentUtcTimeStr) async {
    context.read<AuthBloc>().add(
          UpdateDailyReminderRequested(value, currentUtcTimeStr),
        );
  }

  Future<void> _selectReminderTime(bool currentlyEnabled, String currentUtcTimeStr) async {
    final currentLocalTime = _utcStringToLocalTime(currentUtcTimeStr);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentLocalTime,
    );
    if (picked != null && picked != currentLocalTime) {
      final utcPicked = _localToUtc(picked);
      final newUtcTimeStr = _timeOfDayToUtcString(utcPicked);
      
      context.read<AuthBloc>().add(
            UpdateDailyReminderRequested(currentlyEnabled, newUtcTimeStr),
          );
    }
  }

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: Text('Not authenticated'));
        }

        final user = authState.user;
        final localReminderTime = _utcStringToLocalTime(user.reminderTimeUtc);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent.withAlpha(51), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // Admin Panel (Only visible to admins)
                  if (user.isAdmin) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent),
                      ),
                      title: const Text('Admin Dashboard'),
                      subtitle: const Text('Manage your job postings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: context.read<AuthBloc>()),
                                BlocProvider(create: (_) => sl<JobBloc>()),
                              ],
                              child: const AdminDashboardPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: AppSpacing.xxl),
                  ],

                  // Notification Settings
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notifications_active_outlined, color: AppColors.textPrimary),
                    ),
                    title: const Text('New Job Alerts'),
                    subtitle: const Text('Push notifications for new postings'),
                    trailing: Switch(
                      value: user.notificationEnabled,
                      onChanged: (val) {
                        context.read<AuthBloc>().add(ToggleNotificationsRequested(val));
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.schedule_outlined, color: AppColors.textPrimary),
                    ),
                    title: const Text('Daily Application Reminder'),
                    subtitle: Text(
                      user.dailyReminderEnabled 
                        ? 'Scheduled for ${localReminderTime.format(context)}' 
                        : 'Disabled'
                    ),
                    trailing: Switch(
                      value: user.dailyReminderEnabled,
                      onChanged: (val) => _toggleReminder(val, user.reminderTimeUtc),
                    ),
                    onTap: user.dailyReminderEnabled 
                        ? () => _selectReminderTime(user.dailyReminderEnabled, user.reminderTimeUtc)
                        : null,
                  ),
                  const Divider(height: AppSpacing.xxl),

                  // Logout Button
                  SecondaryButton(
                    text: 'Log Out',
                    icon: Icons.logout,
                    onPressed: () => _onLogout(context),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
