import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';
import 'package:jobnoti/features/auth/domain/repositories/auth_repository.dart';

class ToggleNotifications implements UseCase<UserEntity, bool> {
  final AuthRepository repository;

  ToggleNotifications(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(bool enabled) async {
    return await repository.toggleNotifications(enabled);
  }
}
