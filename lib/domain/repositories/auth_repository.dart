// Interface for authentication repository
// This defines the contract that any auth repository implementation must follow

import 'package:either_dart/either.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  /// Returns Either a Failure or a User entity
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password);

  /// Create user with email and password
  /// Returns Either a Failure or a User entity
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
      String email, String password);

  /// Sign out the current user
  /// Returns Either a Failure or a void for success
  Future<Either<Failure, void>> signOut();

  /// Check if a user is currently authenticated
  /// Returns Either a Failure or a boolean indicating authentication status
  Future<Either<Failure, bool>> isAuthenticated();

  /// Get the current authenticated user
  /// Returns Either a Failure or the current User entity
  Future<Either<Failure, User?>> getCurrentUser();
}
