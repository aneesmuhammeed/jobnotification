import 'package:flutter/material.dart';
import 'package:jobnoti/core/constants/app_colors.dart';
import 'package:jobnoti/core/constants/app_spacing.dart';
import 'package:jobnoti/core/utils/date_time_utils.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';

/// Reusable job card widget used on home screen and admin dashboard.
class JobCard extends StatelessWidget {
  final JobEntity job;
  final bool? isApplied;
  final VoidCallback? onTap;
  final Widget? trailing;

  const JobCard({
    super.key,
    required this.job,
    this.isApplied,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company initial avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        job.companyName.isNotEmpty
                            ? job.companyName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Job info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.companyName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.jobTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Applied badge
                  if (isApplied == true) const _AppliedBadge(),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Bottom row
              Row(
                children: [
                  // Deadline
                  _DeadlineBadge(job: job),
                  const Spacer(),

                  // Trailing widget or "View Details"
                  if (trailing != null)
                    trailing!
                  else
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AppliedBadge extends StatelessWidget {
  const _AppliedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Applied',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final JobEntity job;

  const _DeadlineBadge({required this.job});

  @override
  Widget build(BuildContext context) {
    final isExpired = job.isExpired;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.errorSoft : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.event_busy_outlined : Icons.calendar_today_outlined,
            size: 12,
            color: isExpired ? AppColors.error : AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            isExpired
                ? 'Closed'
                : 'Apply before: ${DateTimeUtils.formatDeadlineShort(job.lastDate)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isExpired ? AppColors.error : AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
