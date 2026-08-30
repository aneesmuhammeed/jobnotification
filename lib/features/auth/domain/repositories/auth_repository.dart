import 'package:dartz/dartz.dart';
import 'package:jobnoti/core/error/failures.dart';
import 'package:jobnoti/features/auth/domain/entities/user_entity.dart';

/// Abstract auth repository — domain layer contract.
abstract class AuthRepository {
  /// Register a new user with email, password, and full name.
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Login with email and password.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Logout the current user.
  Future<Either<Failure, void>> logout();

  /// Get the currently authenticated user, or null if not logged in.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Toggle push notifications for the current user.
  Future<Either<Failure, UserEntity>> toggleNotifications(bool enabled);
}
