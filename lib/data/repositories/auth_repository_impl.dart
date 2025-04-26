import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../infra/adapters/firebase_auth_adapter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthAdapter _firebaseAuthAdapter;

  AuthRepositoryImpl(this._firebaseAuthAdapter);

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential =
          await _firebaseAuthAdapter.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel.fromFirebase(userCredential.user!);
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential =
          await _firebaseAuthAdapter.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel.fromFirebase(userCredential.user!);
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'User creation failed'));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuthAdapter.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final currentUser = _firebaseAuthAdapter.getCurrentUser();
      return Right(currentUser != null);
    } catch (e) {
      return Left(
          AuthFailure(message: 'Authentication check failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuthAdapter.getCurrentUser();

      if (currentUser == null) {
        return const Right(null);
      }

      final user = UserModel.fromFirebase(currentUser);
      return Right(user);
    } catch (e) {
      return Left(
          AuthFailure(message: 'Get current user failed: ${e.toString()}'));
    }
  }
}
