import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:minitok_test/domain/repositories/auth_repository.dart';
import 'package:minitok_test/domain/entities/user.dart';
import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/presentation/cubits/register/register_cubit.dart';
import 'package:minitok_test/presentation/cubits/register/register_state.dart';

// Mock class using mocktail
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late RegisterCubit registerCubit;

  // Test user
  const testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testErrorMessage = 'Something went wrong';

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerCubit = RegisterCubit(mockAuthRepository);
  });

  tearDown(() {
    registerCubit.close();
  });

  test('initial state should be RegisterInitial', () {
    expect(registerCubit.state, const RegisterInitial());
  });

  group('signIn', () {
    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterSuccess] when signIn is successful',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
            testEmail, testPassword)).thenAnswer((_) async => Right(testUser));
        return registerCubit;
      },
      act: (cubit) => cubit.signIn(testEmail, testPassword),
      expect: () => [
        const RegisterLoading(),
        const RegisterSuccess(testUser),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterFailure] when signIn fails',
      build: () {
        when(() =>
            mockAuthRepository.signInWithEmailAndPassword(
                testEmail, testPassword)).thenAnswer(
            (_) async => Left(const AuthFailure(message: testErrorMessage)));
        return registerCubit;
      },
      act: (cubit) => cubit.signIn(testEmail, testPassword),
      expect: () => [
        const RegisterLoading(),
        const RegisterFailure(testErrorMessage),
      ],
    );
  });

  group('signUp', () {
    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterSuccess] when signUp is successful',
      build: () {
        when(() => mockAuthRepository.createUserWithEmailAndPassword(
            testEmail, testPassword)).thenAnswer((_) async => Right(testUser));
        return registerCubit;
      },
      act: (cubit) => cubit.signUp(testEmail, testPassword),
      expect: () => [
        const RegisterLoading(),
        const RegisterSuccess(testUser),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterFailure] when signUp fails',
      build: () {
        when(() =>
            mockAuthRepository.createUserWithEmailAndPassword(
                testEmail, testPassword)).thenAnswer(
            (_) async => Left(const AuthFailure(message: testErrorMessage)));
        return registerCubit;
      },
      act: (cubit) => cubit.signUp(testEmail, testPassword),
      expect: () => [
        const RegisterLoading(),
        const RegisterFailure(testErrorMessage),
      ],
    );
  });

  group('logout', () {
    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterInitial] when logout is successful',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));
        return registerCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const RegisterLoading(),
        const RegisterInitial(),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterLoading, RegisterFailure] when logout fails',
      build: () {
        when(() => mockAuthRepository.signOut()).thenAnswer(
            (_) async => Left(const AuthFailure(message: testErrorMessage)));
        return registerCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const RegisterLoading(),
        const RegisterFailure(testErrorMessage),
      ],
    );
  });

  group('reset', () {
    blocTest<RegisterCubit, RegisterState>(
      'emits [RegisterInitial] when reset is called',
      build: () => registerCubit,
      seed: () => const RegisterFailure('Previous error'),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const RegisterInitial(),
      ],
    );
  });
}
