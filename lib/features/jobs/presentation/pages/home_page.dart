import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/job_card.dart';
import 'package:jobnoti/core/common/widgets/loading_state.dart';
import 'package:jobnoti/core/common/widgets/error_state.dart';
import 'package:jobnoti/core/common/widgets/empty_state.dart';
import 'package:jobnoti/core/utils/date_time_utils.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_event_state.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_bloc.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/pages/job_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<String> _appliedJobIds = {};
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<JobBloc>().add(const LoadJobsRequested());

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ApplicationBloc>().add(
            LoadApplicationsRequested(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userName = authState is Authenticated
        ? authState.user.fullName.split(' ').first
        : 'there';

    return Scaffold(
      body: SafeArea(
        child: BlocListener<ApplicationBloc, ApplicationState>(
          listener: (context, state) {
            if (state is ApplicationsLoaded) {
              setState(() {
                _appliedJobIds = state.applications
                    .map((a) => a.jobId)
                    .toSet();
              });
            }
          },
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.accent,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateTimeUtils.getGreeting()}, $userName',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Available Opportunities',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'all', label: Text('All')),
                            ButtonSegment(value: 'not_applied', label: Text('New')),
                            ButtonSegment(value: 'applied', label: Text('Applied')),
                          ],
                          selected: {_filterStatus},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _filterStatus = newSelection.first;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            selectedForegroundColor: Colors.white,
                            selectedBackgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Job list
                BlocBuilder<JobBloc, JobState>(
                  builder: (context, state) {
                    if (state is JobLoading) {
                      return const SliverFillRemaining(
                        child: LoadingState(),
                      );
                    }

                    if (state is JobError) {
                      return SliverFillRemaining(
                        child: ErrorState(
                          message: state.message,
                          onRetry: _loadData,
                        ),
                      );
                    }

                    if (state is JobsLoaded) {
                      // Filter to only available (active + not expired) jobs
                      var jobs = state.jobs.where((j) => j.isAvailable).toList();

                      if (_filterStatus == 'applied') {
                        jobs = jobs.where((j) => _appliedJobIds.contains(j.id)).toList();
                      } else if (_filterStatus == 'not_applied') {
                        jobs = jobs.where((j) => !_appliedJobIds.contains(j.id)).toList();
                      }

                      if (jobs.isEmpty) {
                        return const SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.work_off_outlined,
                            title: 'No opportunities available',
                            subtitle: 'Check again later for new postings.',
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                        ),
                        sliver: SliverList.separated(
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            final isApplied = _appliedJobIds.contains(job.id);

                            return JobCard(
                              job: job,
                              isApplied: isApplied,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<AuthBloc>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<JobBloc>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<ApplicationBloc>(),
                                        ),
                                      ],
                                      child: JobDetailsPage(jobId: job.id),
                                    ),
                                  ),
                                ).then((_) => _loadData());
                              },
                            );
                          },
                        ),
                      );
                    }

                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.huge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
