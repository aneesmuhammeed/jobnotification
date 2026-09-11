import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/loading_state.dart';
import 'package:jobnoti/core/common/widgets/error_state.dart';
import 'package:jobnoti/core/common/widgets/empty_state.dart';
import 'package:jobnoti/core/utils/date_time_utils.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_bloc.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_event_state.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/jobs/presentation/pages/job_details_page.dart';
import 'package:open_filex/open_filex.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<ApplicationEntity> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ApplicationBloc>().add(
            LoadApplicationsRequested(userId: authState.user.id),
          );
    }
  }

  void _openDocument(String fileId, String documentName) {
    context.read<ApplicationBloc>().add(
          DownloadDocumentRequested(
            fileId: fileId,
            documentName: documentName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadApplications(),
          color: AppColors.accent,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.lg,
                  ),
                  child: Text(
                    'My Applications',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),

              // Applications list
              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {

                  if (state is ApplicationError) {
                    return SliverFillRemaining(
                      child: ErrorState(
                        message: state.message,
                        onRetry: _loadApplications,
                      ),
                    );
                  }

                  if (state is DocumentDownloadInProgress) {
                    // Show a quick loading indicator without breaking the list view
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading document...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    });
                  }

                  if (state is DocumentDownloaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      OpenFilex.open(state.localFilePath);
                    });
                  }

                  if (state is ApplicationsLoaded) {
                    _applications = state.applications;
                  }

                  if (_applications.isEmpty && state is ApplicationLoading) {
                    return const SliverFillRemaining(
                      child: LoadingState(),
                    );
                  }

                  if (_applications.isEmpty) {
                    return const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.folder_open_outlined,
                        title: 'No applications yet',
                        subtitle: 'Jobs you mark as applied will appear here.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: _applications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return _ApplicationCard(
                          application: _applications[index],
                          onOpenDocument: _openDocument,
                        );
                      },
                    ),
                  );
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
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationEntity application;
  final void Function(String, String) onOpenDocument;

  const _ApplicationCard({
    required this.application,
    required this.onOpenDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                child: JobDetailsPage(jobId: application.jobId),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.companyName ?? 'Company',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          application.jobTitle ?? 'Position',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Applied date & View Details
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Applied: ${DateTimeUtils.formatDateTime(application.appliedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),

              // Document
              if (application.hasDocument) ...[
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => onOpenDocument(application.documentPath!, application.documentName ?? 'Document.pdf'),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_outlined,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            application.documentName ?? 'Document',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.accent,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
