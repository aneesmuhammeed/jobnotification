import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';
import 'package:jobnoti/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser extends UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
