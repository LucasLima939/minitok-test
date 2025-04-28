import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:bloc_test/bloc_test.dart';
import 'dart:io';

import 'package:minitok_test/domain/entities/file_item.dart';
import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/presentation/cubits/file_upload/file_upload_cubit.dart';
import 'package:minitok_test/presentation/cubits/file_upload/file_upload_state.dart';
import '../../../mocks/repository_mocks.mocks.dart';

void main() {
  late MockFileRepository mockFileRepository;
  late FileUploadCubit fileUploadCubit;
  late File mockFile;

  // Test data
  final testFileItem = FileItem(
    id: 'test-id-1',
    name: 'test1.pdf',
    url: 'https://example.com/test1.pdf',
    contentType: 'application/pdf',
    size: 1024,
    createdAt: DateTime.now(),
    ownerId: 'user-id',
  );

  const testErrorMessage = 'Failed to upload file';
  const testFileName = 'test1.pdf';
  const testContentType = 'application/pdf';

  // Provide dummy values for Either<Failure, FileItem>
  provideDummy<Either<Failure, FileItem>>(
      Right<Failure, FileItem>(testFileItem));

  setUp(() {
    mockFileRepository = MockFileRepository();
    fileUploadCubit = FileUploadCubit(mockFileRepository);

    // Create a mock File object
    mockFile = File('test.pdf');
  });

  tearDown(() {
    fileUploadCubit.close();
  });

  test('initial state should be FileUploadInitial', () {
    expect(fileUploadCubit.state, isA<FileUploadInitial>());
  });

  group('uploadFile', () {
    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadSuccess] when file upload is successful',
      build: () {
        when(mockFileRepository.uploadFile(
                mockFile, testFileName, testContentType))
            .thenAnswer((_) async => Right(testFileItem));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.uploadFile(mockFile, customFileName: testFileName),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadSuccess(testFileItem),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when file upload fails',
      build: () {
        when(mockFileRepository.uploadFile(
                mockFile, testFileName, testContentType))
            .thenAnswer((_) async =>
                Left(FileOperationFailure(message: testErrorMessage)));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.uploadFile(mockFile, customFileName: testFileName),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadFailure(testErrorMessage),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when exception occurs',
      build: () {
        when(mockFileRepository.uploadFile(
                mockFile, testFileName, testContentType))
            .thenThrow(Exception('Test exception'));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.uploadFile(mockFile, customFileName: testFileName),
      expect: () => [
        isA<FileUploadLoading>(),
        isA<FileUploadFailure>(),
      ],
    );
  });

  group('pickAndUploadImage', () {
    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadSuccess] when image pick and upload is successful',
      build: () {
        when(mockFileRepository.pickAndUploadImage())
            .thenAnswer((_) async => Right(testFileItem));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadImage(),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadSuccess(testFileItem),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when image pick and upload fails',
      build: () {
        when(mockFileRepository.pickAndUploadImage()).thenAnswer(
            (_) async => Left(FileOperationFailure(message: testErrorMessage)));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadImage(),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadFailure(testErrorMessage),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when exception occurs',
      build: () {
        when(mockFileRepository.pickAndUploadImage())
            .thenThrow(Exception('Test exception'));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadImage(),
      expect: () => [
        isA<FileUploadLoading>(),
        isA<FileUploadFailure>(),
      ],
    );
  });

  group('pickAndUploadDocument', () {
    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadSuccess] when document pick and upload is successful',
      build: () {
        when(mockFileRepository.pickAndUploadDocument())
            .thenAnswer((_) async => Right(testFileItem));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadDocument(),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadSuccess(testFileItem),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when document pick and upload fails',
      build: () {
        when(mockFileRepository.pickAndUploadDocument()).thenAnswer(
            (_) async => Left(FileOperationFailure(message: testErrorMessage)));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadDocument(),
      expect: () => [
        isA<FileUploadLoading>(),
        FileUploadFailure(testErrorMessage),
      ],
    );

    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadLoading, FileUploadFailure] when exception occurs',
      build: () {
        when(mockFileRepository.pickAndUploadDocument())
            .thenThrow(Exception('Test exception'));
        return fileUploadCubit;
      },
      act: (cubit) => cubit.pickAndUploadDocument(),
      expect: () => [
        isA<FileUploadLoading>(),
        isA<FileUploadFailure>(),
      ],
    );
  });

  group('reset', () {
    blocTest<FileUploadCubit, FileUploadState>(
      'emits [FileUploadInitial] when reset is called',
      build: () => fileUploadCubit,
      seed: () => FileUploadSuccess(testFileItem),
      act: (cubit) => cubit.reset(),
      expect: () => [
        isA<FileUploadInitial>(),
      ],
    );
  });
}
