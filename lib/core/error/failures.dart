import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

// Unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message: message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}
