import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/core/usecase/usecase.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';
import 'package:jobnoti/features/auth/domain/repositories/auth_repository.dart';

class Register extends UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}
