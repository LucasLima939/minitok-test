import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:minitok_test/infra/adapters/firebase_auth_adapter.dart';

// Generate mocks for Firebase Auth
@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  firebase_auth.UserCredential
])
import 'firebase_auth_adapter_test.mocks.dart';

void main() {
  late FirebaseAuthAdapterImpl firebaseAuthAdapter;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    firebaseAuthAdapter =
        FirebaseAuthAdapterImpl(firebaseAuth: mockFirebaseAuth);
  });

  group('FirebaseAuthAdapter', () {
    test('getCurrentUser should return current user', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = firebaseAuthAdapter.getCurrentUser();

      // Assert
      expect(result, equals(mockUser));
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test(
        'signInWithEmailAndPassword should call FirebaseAuth.signInWithEmailAndPassword',
        () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await firebaseAuthAdapter.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
    });

    test(
        'createUserWithEmailAndPassword should call FirebaseAuth.createUserWithEmailAndPassword',
        () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await firebaseAuthAdapter.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).called(1);
    });

    test('signOut should call FirebaseAuth.signOut', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await firebaseAuthAdapter.signOut();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('authStateChanges should return auth state changes stream', () {
      // Arrange
      final mockStream = Stream<firebase_auth.User?>.fromIterable([mockUser]);
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => mockStream);

      // Act
      final result = firebaseAuthAdapter.authStateChanges;

      // Assert
      expect(result, isA<Stream<firebase_auth.User?>>());
      verify(mockFirebaseAuth.authStateChanges()).called(1);
    });

    test('signInWithEmailAndPassword should throw when FirebaseAuth throws',
        () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrong-password';
      final exception = firebase_auth.FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid',
      );

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => firebaseAuthAdapter.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
        throwsA(isA<firebase_auth.FirebaseAuthException>()),
      );
    });
  });
}
