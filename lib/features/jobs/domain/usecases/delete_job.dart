import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

class DeleteJob extends UseCase<void, DeleteJobParams> {
  final JobRepository repository;

  DeleteJob(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteJobParams params) {
    return repository.deleteJob(params.jobId);
  }
}

class DeleteJobParams extends Equatable {
  final String jobId;

  const DeleteJobParams({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
