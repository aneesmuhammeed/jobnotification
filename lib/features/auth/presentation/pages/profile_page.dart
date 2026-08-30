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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Center(child: Text('Not authenticated'));
    }

    final user = authState.user;

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

              // Admin Panel
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

              // Notification Settings
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                ),
                title: const Text('Push Notifications'),
                trailing: Switch(
                  value: user.notificationEnabled,
                  onChanged: (val) {
                    context.read<AuthBloc>().add(ToggleNotificationsRequested(val));
                  },
                ),
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
}
