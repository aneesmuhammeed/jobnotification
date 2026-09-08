import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';

/// Abstract application repository — domain layer contract.
abstract class ApplicationRepository {
  /// Mark a job as applied for the current user.
  Future<Either<Failure, ApplicationEntity>> markAsApplied({
    required String userId,
    required String jobId,
    String? documentPath,
    String? documentName,
  });

  /// Get all applications for a specific user.
  Future<Either<Failure, List<ApplicationEntity>>> getApplications(String userId);

  /// Get a specific application by user and job.
  Future<Either<Failure, ApplicationEntity?>> getApplicationByJob({
    required String userId,
    required String jobId,
  });

  /// Download a document from Telegram and get the local file path.
  Future<Either<Failure, String>> downloadDocument(String fileId, String documentName);
}
