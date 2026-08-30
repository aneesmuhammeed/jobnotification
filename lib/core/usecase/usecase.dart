import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jobnoti/core/error/failures.dart';

/// Base use case contract.
///
/// [Type] is the return type on success.
/// [Params] is the parameter object passed to the use case.
///
/// Every use case returns `Either<Failure, Type>` to handle
/// success and error cases uniformly.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when a use case requires no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
