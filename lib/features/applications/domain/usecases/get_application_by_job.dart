import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';

class GetApplicationByJob extends UseCase<ApplicationEntity?, GetApplicationByJobParams> {
  final ApplicationRepository repository;

  GetApplicationByJob(this.repository);

  @override
  Future<Either<Failure, ApplicationEntity?>> call(GetApplicationByJobParams params) {
    return repository.getApplicationByJob(
      userId: params.userId,
      jobId: params.jobId,
    );
  }
}

class GetApplicationByJobParams extends Equatable {
  final String userId;
  final String jobId;

  const GetApplicationByJobParams({
    required this.userId,
    required this.jobId,
  });

  @override
  List<Object?> get props => [userId, jobId];
}
