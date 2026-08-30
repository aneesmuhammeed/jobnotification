import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

class CreateJob extends UseCase<JobEntity, CreateJobParams> {
  final JobRepository repository;

  CreateJob(this.repository);

  @override
  Future<Either<Failure, JobEntity>> call(CreateJobParams params) {
    return repository.createJob(
      companyName: params.companyName,
      jobTitle: params.jobTitle,
      description: params.description,
      applicationUrl: params.applicationUrl,
      lastDate: params.lastDate,
      createdBy: params.createdBy,
    );
  }
}

class CreateJobParams extends Equatable {
  final String companyName;
  final String jobTitle;
  final String description;
  final String applicationUrl;
  final DateTime lastDate;
  final String createdBy;

  const CreateJobParams({
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.applicationUrl,
    required this.lastDate,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        companyName, jobTitle, description,
        applicationUrl, lastDate, createdBy,
      ];
}
