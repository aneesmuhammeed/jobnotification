import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/job_card.dart';
import 'package:jobnoti/core/common/widgets/loading_state.dart';
import 'package:jobnoti/core/common/widgets/error_state.dart';
import 'package:jobnoti/core/common/widgets/empty_state.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/pages/add_edit_job_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<JobBloc>().add(LoadAdminJobsRequested(adminId: authState.user.id));
    }
  }

  void _confirmDelete(String jobId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<JobBloc>().add(DeleteJobRequested(jobId: jobId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<AuthBloc>()),
                      BlocProvider.value(value: context.read<JobBloc>()),
                    ],
                    child: const AddEditJobPage(),
                  ),
                ),
              ).then((_) => _loadJobs());
            },
          ),
        ],
      ),
      body: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job deleted successfully')),
            );
            _loadJobs();
          } else if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is JobLoading) {
            return const LoadingState();
          }

          if (state is JobError) {
            return ErrorState(
              message: state.message,
              onRetry: _loadJobs,
            );
          }

          if (state is JobsLoaded) {
            final jobs = state.jobs;
            
            if (jobs.isEmpty) {
              return const EmptyState(
                icon: Icons.work_off_outlined,
                title: 'No jobs posted',
                subtitle: 'Tap the + icon to create your first job posting.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadJobs(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return JobCard(
                    job: job,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<AuthBloc>()),
                                    BlocProvider.value(value: context.read<JobBloc>()),
                                  ],
                                  child: AddEditJobPage(jobToEdit: job),
                                ),
                              ),
                            ).then((_) => _loadJobs());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(job.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
