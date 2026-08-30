import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/jobs/domain/entities/job_entity.dart';
import 'package:jobnoti/features/jobs/domain/repositories/job_repository.dart';

class GetJobs extends UseCase<List<JobEntity>, NoParams> {
  final JobRepository repository;

  GetJobs(this.repository);

  @override
  Future<Either<Failure, List<JobEntity>>> call(NoParams params) {
    return repository.getJobs();
  }
}
