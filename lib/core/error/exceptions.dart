/// Exception thrown when a server/API call fails.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'An unexpected server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when a local cache/storage operation fails.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local storage error.']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when a duplicate record is attempted.
class DuplicateException implements Exception {
  final String message;
  const DuplicateException([this.message = 'Duplicate record.']);

  @override
  String toString() => 'DuplicateException: $message';
}
