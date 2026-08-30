import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

class GetJobById extends UseCase<JobEntity, GetJobByIdParams> {
  final JobRepository repository;

  GetJobById(this.repository);

  @override
  Future<Either<Failure, JobEntity>> call(GetJobByIdParams params) {
    return repository.getJobById(params.jobId);
  }
}

class GetJobByIdParams extends Equatable {
  final String jobId;

  const GetJobByIdParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
