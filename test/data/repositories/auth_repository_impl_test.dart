import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/domain/entities/user.dart' as domain;
import 'package:minitok_test/data/repositories/auth_repository_impl.dart';
import 'package:minitok_test/infra/adapters/firebase_auth_adapter.dart';

// Generate mocks for FirebaseAuthAdapter
@GenerateMocks([
  FirebaseAuthAdapter,
  firebase_auth.User,
  firebase_auth.UserCredential,
])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late MockFirebaseAuthAdapter mockFirebaseAuthAdapter;
  late AuthRepositoryImpl authRepository;

  // Test user data
  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUid = 'user123';
  final testDisplayName = 'Test User';

  // Mock Firebase user and user credential
  late MockUser mockFirebaseUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuthAdapter = MockFirebaseAuthAdapter();
    authRepository = AuthRepositoryImpl(mockFirebaseAuthAdapter);

    // Set up mock Firebase user
    mockFirebaseUser = MockUser();
    when(mockFirebaseUser.uid).thenReturn(testUid);
    when(mockFirebaseUser.email).thenReturn(testEmail);
    when(mockFirebaseUser.displayName).thenReturn(testDisplayName);
    when(mockFirebaseUser.photoURL).thenReturn(null);

    // Set up mock user credential
    mockUserCredential = MockUserCredential();
    when(mockUserCredential.user).thenReturn(mockFirebaseUser);
  });

  group('signInWithEmailAndPassword', () {
    test('should return User when sign in is successful', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await authRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right.id, testUid);
      expect(result.right.email, testEmail);
      expect(result.right.displayName, testDisplayName);

      verify(mockFirebaseAuthAdapter.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return AuthFailure when sign in fails', () async {
      // Arrange
      final exception = firebase_auth.FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is invalid',
      );

      when(mockFirebaseAuthAdapter.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(exception);

      // Act
      final result = await authRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'The email address is invalid');

      verify(mockFirebaseAuthAdapter.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });
  });

  group('createUserWithEmailAndPassword', () {
    test('should return User when user creation is successful', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await authRepository.createUserWithEmailAndPassword(
        testEmail,
        testPassword,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right.id, testUid);
      expect(result.right.email, testEmail);
      expect(result.right.displayName, testDisplayName);

      verify(mockFirebaseAuthAdapter.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return AuthFailure when user creation fails', () async {
      // Arrange
      final exception = firebase_auth.FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use',
      );

      when(mockFirebaseAuthAdapter.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(exception);

      // Act
      final result = await authRepository.createUserWithEmailAndPassword(
        testEmail,
        testPassword,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'The email address is already in use');

      verify(mockFirebaseAuthAdapter.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      ));
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });
  });

  group('signOut', () {
    test('should return Right(null) when sign out is successful', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.signOut()).thenAnswer((_) async {});

      // Act
      final result = await authRepository.signOut();

      // Assert
      expect(result.isRight, true);

      verify(mockFirebaseAuthAdapter.signOut());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return AuthFailure when sign out fails', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act
      final result = await authRepository.signOut();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, contains('Sign out failed'));

      verify(mockFirebaseAuthAdapter.signOut());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });
  });

  group('isAuthenticated', () {
    test('should return true when user is authenticated', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser())
          .thenReturn(mockFirebaseUser);

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result.isRight, true);
      expect(result.right, true);

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return false when user is not authenticated', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result.isRight, true);
      expect(result.right, false);

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return AuthFailure when checking authentication fails',
        () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser())
          .thenThrow(Exception('Auth check failed'));

      // Act
      final result = await authRepository.isAuthenticated();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, contains('Authentication check failed'));

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });
  });

  group('getCurrentUser', () {
    test('should return User when user is authenticated', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser())
          .thenReturn(mockFirebaseUser);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result.isRight, true);
      expect(result.right, isA<domain.User>());
      expect(result.right?.id, testUid);
      expect(result.right?.email, testEmail);
      expect(result.right?.displayName, testDisplayName);

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return null when user is not authenticated', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result.isRight, true);
      expect(result.right, null);

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });

    test('should return AuthFailure when getting current user fails', () async {
      // Arrange
      when(mockFirebaseAuthAdapter.getCurrentUser())
          .thenThrow(Exception('Get user failed'));

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, contains('Get current user failed'));

      verify(mockFirebaseAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockFirebaseAuthAdapter);
    });
  });
}
