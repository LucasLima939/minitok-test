import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:minitok_test/domain/entities/file_item.dart';
import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/presentation/cubits/file_list/file_list_cubit.dart';
import 'package:minitok_test/presentation/cubits/file_list/file_list_state.dart';
import '../../../mocks/repository_mocks.mocks.dart';

void main() {
  late MockFileRepository mockFileRepository;
  late FileListCubit fileListCubit;

  // Test data
  final testFiles = [
    FileItem(
      id: 'test-id-1',
      name: 'test1.pdf',
      url: 'https://example.com/test1.pdf',
      contentType: 'application/pdf',
      size: 1024,
      createdAt: DateTime.now(),
      ownerId: 'user-id',
    ),
    FileItem(
      id: 'test-id-2',
      name: 'test2.jpg',
      url: 'https://example.com/test2.jpg',
      contentType: 'image/jpeg',
      size: 2048,
      createdAt: DateTime.now(),
      ownerId: 'user-id',
    ),
  ];

  const testErrorMessage = 'Failed to load files';

  // Provide a dummy value for Either<Failure, List<FileItem>>
  provideDummy<Either<Failure, List<FileItem>>>(
      Right<Failure, List<FileItem>>([]));

  setUp(() {
    mockFileRepository = MockFileRepository();
    fileListCubit = FileListCubit(mockFileRepository);
  });

  tearDown(() {
    fileListCubit.close();
  });

  test('initial state should be FileListInitial', () {
    expect(fileListCubit.state, isA<FileListInitial>());
  });

  group('loadFiles', () {
    blocTest<FileListCubit, FileListState>(
      'emits [FileListLoading, FileListLoaded] when loading files is successful',
      build: () {
        when(mockFileRepository.getFiles())
            .thenAnswer((_) async => Right(testFiles));
        return fileListCubit;
      },
      act: (cubit) => cubit.loadFiles(),
      expect: () => [
        isA<FileListLoading>(),
        FileListLoaded(testFiles),
      ],
    );

    blocTest<FileListCubit, FileListState>(
      'emits [FileListLoading, FileListError] when loading files fails',
      build: () {
        when(mockFileRepository.getFiles()).thenAnswer(
            (_) async => Left(FileOperationFailure(message: testErrorMessage)));
        return fileListCubit;
      },
      act: (cubit) => cubit.loadFiles(),
      expect: () => [
        isA<FileListLoading>(),
        FileListError(testErrorMessage),
      ],
    );
  });

  group('refreshFiles', () {
    blocTest<FileListCubit, FileListState>(
      'emits [FileListLoaded] when refresh is successful',
      build: () {
        when(mockFileRepository.getFiles())
            .thenAnswer((_) async => Right(testFiles));
        return fileListCubit;
      },
      seed: () => FileListLoaded([]), // Initial state with empty list
      act: (cubit) => cubit.refreshFiles(),
      expect: () => [
        FileListLoaded(testFiles),
      ],
    );

    blocTest<FileListCubit, FileListState>(
      'emits [FileListError] when refresh fails',
      build: () {
        when(mockFileRepository.getFiles()).thenAnswer(
            (_) async => Left(FileOperationFailure(message: testErrorMessage)));
        return fileListCubit;
      },
      seed: () => FileListLoaded([]), // Initial state with empty list
      act: (cubit) => cubit.refreshFiles(),
      expect: () => [
        FileListError(testErrorMessage),
      ],
    );

    blocTest<FileListCubit, FileListState>(
      'does not emit any state when already loading',
      build: () => fileListCubit,
      seed: () => FileListLoading(),
      act: (cubit) => cubit.refreshFiles(),
      expect: () => [],
    );
  });
}
