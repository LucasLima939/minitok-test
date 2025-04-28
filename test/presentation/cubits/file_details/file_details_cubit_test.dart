import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:minitok_test/domain/entities/file_item.dart';
import 'package:minitok_test/core/error/failures.dart' as failures;
import 'package:minitok_test/presentation/cubits/file_details/file_details_cubit.dart';
import 'package:minitok_test/presentation/cubits/file_details/file_details_state.dart';
import '../../../mocks/repository_mocks.mocks.dart';

void main() {
  late MockFileRepository mockFileRepository;
  late FileDetailsCubit fileDetailsCubit;
  late File mockDownloadedFile;

  // Test data
  final testFile = FileItem(
    id: 'test-id',
    name: 'test.pdf',
    url: 'https://example.com/test.pdf',
    contentType: 'application/pdf',
    size: 1024,
    createdAt: DateTime.now(),
    ownerId: 'user-id',
  );

  const testErrorMessage = 'Operation failed';

  // Provide dummy values for Either types used in Mockito
  setUp(() {
    mockFileRepository = MockFileRepository();
    mockDownloadedFile = File('test/fixtures/downloaded.pdf');
    fileDetailsCubit = FileDetailsCubit(mockFileRepository);

    // Provide dummy values for Either types
    provideDummy<Either<failures.Failure, File>>(
        Left(failures.FileOperationFailure(message: 'dummy')));
    provideDummy<Either<failures.Failure, String>>(
        Left(failures.FileOperationFailure(message: 'dummy')));
    provideDummy<Either<failures.Failure, void>>(
        Left(failures.FileOperationFailure(message: 'dummy')));
  });

  tearDown(() {
    fileDetailsCubit.close();
  });

  test('initial state should be FileDetailsInitial', () {
    expect(fileDetailsCubit.state, isA<FileDetailsInitial>());
  });

  group('downloadFile', () {
    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileDownloadLoading, FileDownloadSuccess] when download is successful',
      build: () {
        when(mockFileRepository.downloadFile(testFile))
            .thenAnswer((_) async => Right(mockDownloadedFile));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.downloadFile(testFile),
      expect: () => [
        isA<FileDownloadLoading>(),
        FileDownloadSuccess(mockDownloadedFile),
      ],
    );

    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileDownloadLoading, FileOperationFailure] when download fails',
      build: () {
        when(mockFileRepository.downloadFile(testFile)).thenAnswer((_) async =>
            Left(failures.FileOperationFailure(message: testErrorMessage)));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.downloadFile(testFile),
      expect: () => [
        isA<FileDownloadLoading>(),
        isA<FileOperationFailure>(),
      ],
    );
  });

  group('shareFile', () {
    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileShareLoading, FileShareSuccess] when share is successful',
      build: () {
        when(mockFileRepository.shareFile(testFile))
            .thenAnswer((_) async => Right(testFile.url));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.shareFile(testFile),
      expect: () => [
        isA<FileShareLoading>(),
        FileShareSuccess(testFile.url),
      ],
    );

    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileShareLoading, FileOperationFailure] when share fails',
      build: () {
        when(mockFileRepository.shareFile(testFile)).thenAnswer((_) async =>
            Left(failures.FileOperationFailure(message: testErrorMessage)));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.shareFile(testFile),
      expect: () => [
        isA<FileShareLoading>(),
        isA<FileOperationFailure>(),
      ],
    );
  });

  group('deleteFile', () {
    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileDeleteLoading, FileDeleteSuccess] when delete is successful',
      build: () {
        when(mockFileRepository.deleteFile(testFile.id))
            .thenAnswer((_) async => const Right(null));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.deleteFile(testFile),
      expect: () => [
        isA<FileDeleteLoading>(),
        FileDeleteSuccess(testFile),
      ],
    );

    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileDeleteLoading, FileOperationFailure] when delete fails',
      build: () {
        when(mockFileRepository.deleteFile(testFile.id)).thenAnswer((_) async =>
            Left(failures.FileOperationFailure(message: testErrorMessage)));
        return fileDetailsCubit;
      },
      act: (cubit) => cubit.deleteFile(testFile),
      expect: () => [
        isA<FileDeleteLoading>(),
        isA<FileOperationFailure>(),
      ],
    );
  });

  group('reset', () {
    blocTest<FileDetailsCubit, FileDetailsState>(
      'emits [FileDetailsInitial] when reset is called',
      build: () => fileDetailsCubit,
      seed: () => FileOperationFailure(
        operation: 'test',
        message: 'Previous error',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [
        isA<FileDetailsInitial>(),
      ],
    );
  });
}
