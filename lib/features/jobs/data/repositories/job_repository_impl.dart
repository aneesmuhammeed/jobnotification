import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/exceptions.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:jobnoti/features/jobs/data/models/job_model.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

/// Concrete implementation of [JobRepository].
class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs() async {
    try {
      final jobs = await remoteDataSource.getJobs();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<JobEntity>>> getJobsByAdmin(String adminId) async {
    try {
      final jobs = await remoteDataSource.getJobsByAdmin(adminId);
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobById(String jobId) async {
    try {
      final job = await remoteDataSource.getJobById(jobId);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> createJob({
    required String companyName,
    required String jobTitle,
    required String description,
    required String applicationUrl,
    required DateTime lastDate,
    required String createdBy,
  }) async {
    try {
      final jobModel = JobModel(
        id: '',
        companyName: companyName,
        jobTitle: jobTitle,
        description: description,
        applicationUrl: applicationUrl,
        lastDate: lastDate,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        isActive: true,
      );
      final job = await remoteDataSource.createJob(jobModel.toInsertJson());
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> updateJob({
    required String jobId,
    required String companyName,
    required String jobTitle,
    required String description,
    required String applicationUrl,
    required DateTime lastDate,
    required bool isActive,
  }) async {
    try {
      final data = {
        'company_name': companyName,
        'job_title': jobTitle,
        'description': description,
        'application_url': applicationUrl,
        'last_date': lastDate.toIso8601String().split('T').first,
        'is_active': isActive,
      };
      final job = await remoteDataSource.updateJob(jobId, data);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJob(String jobId) async {
    try {
      await remoteDataSource.deleteJob(jobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
