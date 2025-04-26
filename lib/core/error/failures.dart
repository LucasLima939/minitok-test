// Base class for all failures in the application
// This allows us to handle errors in a consistent way

abstract class Failure {
  final String message;

  const Failure({required this.message});
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

// Connection failures
class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message});
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

// File operation failures
class FileOperationFailure extends Failure {
  const FileOperationFailure({required super.message});
}
