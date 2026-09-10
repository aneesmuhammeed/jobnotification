import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

class UpdateJob extends UseCase<JobEntity, UpdateJobParams> {
  final JobRepository repository;

  UpdateJob(this.repository);

  @override
  Future<Either<Failure, JobEntity>> call(UpdateJobParams params) {
    return repository.updateJob(
      jobId: params.jobId,
      companyName: params.companyName,
      jobTitle: params.jobTitle,
      description: params.description,
      applicationUrls: params.applicationUrls,
      lastDate: params.lastDate,
      isActive: params.isActive,
    );
  }
}

class UpdateJobParams extends Equatable {
  final String jobId;
  final String companyName;
  final String jobTitle;
  final String description;
  final List<String> applicationUrls;
  final DateTime lastDate;
  final bool isActive;

  const UpdateJobParams({
    required this.jobId,
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.applicationUrls,
    required this.lastDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        jobId, companyName, jobTitle, description,
        applicationUrls, lastDate, isActive,
      ];
}
