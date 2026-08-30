import 'package:equatable/equatable.dart';

/// Base failure class for domain-layer error handling.
/// All specific failures extend this.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure originating from server/API calls.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected server error occurred.']);
}

/// Failure originating from authentication operations.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Failure originating from local cache/storage.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error occurred.']);
}

/// Failure when there's no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please try again.']);
}

/// Failure when a duplicate record is attempted.
class DuplicateFailure extends Failure {
  const DuplicateFailure([super.message = 'This record already exists.']);
}

/// Failure when the requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}
