import 'dart:io';
import 'package:jobnoti/core/services/telegram_service.dart';
import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/exceptions.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/applications/data/datasources/application_remote_data_source.dart';
import 'package:jobnoti/features/applications/data/models/application_model.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';

/// Concrete implementation of [ApplicationRepository].
class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;
  final TelegramService telegramService;

  ApplicationRepositoryImpl({
    required this.remoteDataSource,
    required this.telegramService,
  });

  @override
  Future<Either<Failure, ApplicationEntity>> markAsApplied({
    required String userId,
    required String jobId,
    String? documentPath,
    String? documentName,
  }) async {
    try {
      String? finalDocumentPath = documentPath;

      // If a document was provided, upload it to Telegram first
      if (documentPath != null && documentName != null) {
        final file = File(documentPath);
        if (await file.exists()) {
          final fileId = await telegramService.uploadDocument(file, documentName);
          finalDocumentPath = fileId; // Store the file_id instead of local path!
        }
      }

      final model = ApplicationModel(
        id: '',
        userId: userId,
        jobId: jobId,
        appliedAt: DateTime.now(),
        documentPath: finalDocumentPath,
        documentName: documentName,
      );
      final application = await remoteDataSource.markAsApplied(model.toInsertJson());
      return Right(application);
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getApplications(String userId) async {
    try {
      final applications = await remoteDataSource.getApplications(userId);
      return Right(applications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity?>> getApplicationByJob({
    required String userId,
    required String jobId,
  }) async {
    try {
      final application = await remoteDataSource.getApplicationByJob(
        userId: userId,
        jobId: jobId,
      );
      return Right(application);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> downloadDocument(String fileId, String documentName) async {
    try {
      final localPath = await telegramService.downloadDocument(fileId, documentName);
      return Right(localPath);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
