import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';
import 'package:jobnoti/features/auth/domain/repositories/auth_repository.dart';

class UpdateDailyReminder implements UseCase<UserEntity, UpdateDailyReminderParams> {
  final AuthRepository repository;

  UpdateDailyReminder(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateDailyReminderParams params) async {
    return await repository.updateDailyReminder(params.enabled, params.timeUtc);
  }
}

class UpdateDailyReminderParams extends Equatable {
  final bool enabled;
  final String timeUtc;

  const UpdateDailyReminderParams({required this.enabled, required this.timeUtc});

  @override
  List<Object?> get props => [enabled, timeUtc];
}
