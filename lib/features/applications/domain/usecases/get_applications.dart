import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';

class GetApplications extends UseCase<List<ApplicationEntity>, GetApplicationsParams> {
  final ApplicationRepository repository;

  GetApplications(this.repository);

  @override
  Future<Either<Failure, List<ApplicationEntity>>> call(GetApplicationsParams params) {
    return repository.getApplications(params.userId);
  }
}

class GetApplicationsParams extends Equatable {
  final String userId;

  const GetApplicationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
