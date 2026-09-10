import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/common/widgets/primary_button.dart';
import 'package:jobnoti/core/common/widgets/loading_state.dart';
import 'package:jobnoti/core/common/widgets/error_state.dart';
import 'package:jobnoti/core/utils/date_time_utils.dart';
import 'package:jobnoti/core/utils/url_launcher_utils.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:jobnoti/features/auth/presentation/bloc/auth_event_state.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:jobnoti/features/jobs/presentation/bloc/job_event_state.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_bloc.dart';
import 'package:jobnoti/features/applications/presentation/bloc/application_event_state.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:jobnoti/core/constants/app_constants.dart';
import 'package:open_filex/open_filex.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;

  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  ApplicationEntity? _application;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
    _checkApplicationStatus();
  }

  void _loadJobDetails() {
    context.read<JobBloc>().add(LoadJobDetailsRequested(jobId: widget.jobId));
  }

  void _checkApplicationStatus() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ApplicationBloc>().add(
            CheckApplicationStatusRequested(
              userId: authState.user.id,
              jobId: widget.jobId,
            ),
          );
    }
  }

  Future<void> _markAsApplied() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Show confirmation dialog with optional document upload
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (dialogContext) => _MarkAppliedDialog(),
    );

    if (result == null) return; // User cancelled

    if (!mounted) return;

    context.read<ApplicationBloc>().add(
          MarkAsAppliedRequested(
            userId: authState.user.id,
            jobId: widget.jobId,
            documentPath: result['documentPath'],
            documentName: result['documentName'],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ApplicationBloc, ApplicationState>(
            listener: (context, state) {
              if (state is ApplicationStatusChecked) {
                setState(() {
                  _application = state.application;
                  _checkingStatus = false;
                });
              }
              if (state is ApplicationMarked) {
                setState(() {
                  _application = state.application;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marked as applied successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
              if (state is ApplicationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              if (state is DocumentDownloadInProgress) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading document...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              if (state is DocumentDownloaded) {
                OpenFilex.open(state.localFilePath);
              }
            },
          ),
        ],
        child: BlocBuilder<JobBloc, JobState>(
          builder: (context, state) {
            if (state is JobLoading) {
              return const LoadingState();
            }

            if (state is JobError) {
              return ErrorState(
                message: state.message,
                onRetry: _loadJobDetails,
              );
            }

            if (state is JobDetailLoaded) {
              return _buildJobDetails(context, state.job);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildJobDetails(BuildContext context, JobEntity job) {
    final hasApplied = _application != null;
    final isExpired = job.isExpired;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company avatar + name
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: Text(
                    job.companyName.isNotEmpty
                        ? job.companyName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.companyName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.jobTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Expired badge
          if (isExpired)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_busy, size: 18, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Application Closed',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ],
              ),
            ),

          if (isExpired) const SizedBox(height: AppSpacing.lg),

          // Description section
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            job.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Last Date
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Last Date',
            value: DateTimeUtils.formatDateLong(job.lastDate),
          ),
          const SizedBox(height: AppSpacing.md),

          // Posted date
          _DetailRow(
            icon: Icons.schedule_outlined,
            label: 'Posted',
            value: DateTimeUtils.formatDate(job.createdAt),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Applied status
          if (hasApplied) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.success.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Applied',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.success,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Applied on: ${DateTimeUtils.formatDateTime(_application!.appliedAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_application!.hasDocument) ...[
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: () => _openDocument(_application!.documentPath!, _application!.documentName ?? 'Document.pdf'),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined,
                              size: 16, color: AppColors.accent),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _application!.documentName ?? 'Document',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.accent,
                                    decoration: TextDecoration.underline,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Action buttons (only if not expired and not already applied)
          if (!isExpired && !hasApplied && !_checkingStatus) ...[
            if (job.applicationUrls.isNotEmpty)
              ...job.applicationUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: PrimaryButton(
                      text: job.applicationUrls.length > 1 ? 'Apply Now (Link ${job.applicationUrls.indexOf(url) + 1})' : 'Apply Now',
                      icon: Icons.open_in_new_rounded,
                      onPressed: () => UrlLauncherUtils.openUrl(url),
                    ),
                  )),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              text: 'Mark as Applied',
              icon: Icons.check_circle_outline,
              onPressed: _markAsApplied,
            ),
          ],
        ],
      ),
    );
  }

  void _openDocument(String fileId, String documentName) {
    context.read<ApplicationBloc>().add(
          DownloadDocumentRequested(
            fileId: fileId,
            documentName: documentName,
          ),
        );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

/// Dialog for marking a job as applied, with optional document upload.
class _MarkAppliedDialog extends StatefulWidget {
  @override
  State<_MarkAppliedDialog> createState() => _MarkAppliedDialogState();
}

class _MarkAppliedDialogState extends State<_MarkAppliedDialog> {
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isPickingFile = false;

  Future<void> _pickDocument() async {
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );

      if (result.isNotEmpty) {
        final file = result.first;

        setState(() {
          _selectedFileName = file.name;
          _selectedFilePath = file.path;
        });
      }
    } catch (e) {
      // Silently handle file picker errors
    } finally {
      setState(() => _isPickingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Applied'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mark this job as applied?'),
          const SizedBox(height: AppSpacing.lg),

          // Document upload
          if (_selectedFileName != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedFileName = null;
                        _selectedFilePath = null;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _isPickingFile ? null : _pickDocument,
              icon: _isPickingFile
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.attach_file, size: 18),
              label: Text(_isPickingFile ? 'Selecting...' : 'Attach Resume (optional)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'documentPath': _selectedFilePath,
              'documentName': _selectedFileName,
            });
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
