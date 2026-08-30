import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';

/// Abstract job repository — domain layer contract.
abstract class JobRepository {
  /// Get all active jobs (for normal users).
  Future<Either<Failure, List<JobEntity>>> getJobs();

  /// Get all jobs created by a specific admin.
  Future<Either<Failure, List<JobEntity>>> getJobsByAdmin(String adminId);

  /// Get a single job by its ID.
  Future<Either<Failure, JobEntity>> getJobById(String jobId);

  /// Create a new job posting.
  Future<Either<Failure, JobEntity>> createJob({
    required String companyName,
    required String jobTitle,
    required String description,
    required String applicationUrl,
    required DateTime lastDate,
    required String createdBy,
  });

  /// Update an existing job.
  Future<Either<Failure, JobEntity>> updateJob({
    required String jobId,
    required String companyName,
    required String jobTitle,
    required String description,
    required String applicationUrl,
    required DateTime lastDate,
    required bool isActive,
  });

  /// Delete a job by its ID.
  Future<Either<Failure, void>> deleteJob(String jobId);
}
