import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/applications/domain/entities/application_entity.dart';
import 'package:jobnoti/features/applications/domain/repositories/application_repository.dart';

class MarkJobAsApplied extends UseCase<ApplicationEntity, MarkJobAsAppliedParams> {
  final ApplicationRepository repository;

  MarkJobAsApplied(this.repository);

  @override
  Future<Either<Failure, ApplicationEntity>> call(MarkJobAsAppliedParams params) {
    return repository.markAsApplied(
      userId: params.userId,
      jobId: params.jobId,
      documentPath: params.documentPath,
      documentName: params.documentName,
    );
  }
}

class MarkJobAsAppliedParams extends Equatable {
  final String userId;
  final String jobId;
  final String? documentPath;
  final String? documentName;

  const MarkJobAsAppliedParams({
    required this.userId,
    required this.jobId,
    this.documentPath,
    this.documentName,
  });

  @override
  List<Object?> get props => [userId, jobId, documentPath, documentName];
}
