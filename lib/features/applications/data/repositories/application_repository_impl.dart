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

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ApplicationEntity>> markAsApplied({
    required String userId,
    required String jobId,
    String? documentPath,
    String? documentName,
  }) async {
    try {
      final model = ApplicationModel(
        id: '',
        userId: userId,
        jobId: jobId,
        appliedAt: DateTime.now(),
        documentPath: documentPath,
        documentName: documentName,
      );
      final application = await remoteDataSource.markAsApplied(model.toInsertJson());
      return Right(application);
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
}
