import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/data/repositories/file_repository_impl.dart';
import 'package:minitok_test/infra/adapters/firebase_storage_adapter.dart';
import 'package:minitok_test/infra/adapters/firebase_auth_adapter.dart';

// Generate mocks for adapters
@GenerateMocks([
  FirebaseStorageAdapter,
  FirebaseAuthAdapter,
  firebase_storage.FullMetadata,
  firebase_storage.Reference,
  firebase_auth.User,
])
import 'file_repository_impl_test.mocks.dart';

void main() {
  late MockFirebaseStorageAdapter mockStorageAdapter;
  late MockFirebaseAuthAdapter mockAuthAdapter;
  late FileRepositoryImpl fileRepository;
  late MockUser mockUser;
  late MockReference mockFileRef;
  late MockFullMetadata mockMetadata;

  // Test data
  final testUserId = 'user123';
  final testFileId = 'file123';
  final testFileName = 'test_file.pdf';
  final testContentType = 'application/pdf';
  final testFileUrl = 'https://example.com/files/test_file.pdf';

  setUp(() {
    mockUser = MockUser();
    mockFileRef = MockReference();
    mockMetadata = MockFullMetadata();
    mockStorageAdapter = MockFirebaseStorageAdapter();
    mockAuthAdapter = MockFirebaseAuthAdapter();
    fileRepository = FileRepositoryImpl(mockStorageAdapter, mockAuthAdapter);

    // Setup common stubs
    when(mockUser.uid).thenReturn(testUserId);
    when(mockFileRef.name).thenReturn(testFileId);
    when(mockFileRef.fullPath).thenReturn('files/$testUserId/$testFileId');
    when(mockMetadata.contentType).thenReturn(testContentType);
    when(mockMetadata.size).thenReturn(1024); // 1kb
    when(mockMetadata.timeCreated).thenReturn(DateTime.now());
    when(mockMetadata.name).thenReturn(testFileName);
  });

  group('getFiles', () {
    test('should return list of files when user is authenticated', () async {
      // Arrange
      final fileReferences = [
        mockFileRef,
      ];

      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.listFiles('files/$testUserId'))
          .thenAnswer((_) async => fileReferences);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => testFileUrl);
      when(mockFileRef.getMetadata()).thenAnswer((_) async => mockMetadata);

      // Act
      final result = await fileRepository.getFiles();

      // Assert
      expect(result.isRight, true);
      expect(result.right.length,
          1); // Only one file reference in our mocked response
      expect(result.right[0].name,
          testFileId); // Using the file ID as name since that's what's returned by mockFileRef.name

      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.listFiles('files/$testUserId'));
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
      verify(mockFileRef.getMetadata());
      verifyNoMoreInteractions(mockAuthAdapter);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await fileRepository.getFiles();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'User not authenticated');

      verify(mockAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockAuthAdapter);
      verifyNoMoreInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when getting files fails',
        () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.listFiles('files/$testUserId'))
          .thenThrow(Exception('Failed to list files'));

      // Act
      final result = await fileRepository.getFiles();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to retrieve files'));

      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.listFiles('files/$testUserId'));
      verifyNoMoreInteractions(mockAuthAdapter);
    });
  });

  group('uploadFile', () {
    test('should return uploaded file when successful', () async {
      // Arrange
      final testFile = File('test/fixtures/sample.pdf');

      // Create a temporary file for testing if it doesn't exist
      if (!testFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testFile.writeAsStringSync('Test content');
      }

      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => testFileUrl);

      // Act
      final result = await fileRepository.uploadFile(
        testFile,
        testFileName,
        testContentType,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right.name, testFileName);
      expect(result.right.url, testFileUrl);
      expect(result.right.contentType, testContentType);
      expect(result.right.ownerId, testUserId);

      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
      verifyNoMoreInteractions(mockAuthAdapter);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      final testFile = File('test/fixtures/sample.pdf');
      when(mockAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await fileRepository.uploadFile(
        testFile,
        testFileName,
        testContentType,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'User not authenticated');

      verify(mockAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockAuthAdapter);
      verifyNoMoreInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when upload fails', () async {
      // Arrange
      final testFile = File('test/fixtures/sample.pdf');

      // Create a temporary file for testing if it doesn't exist
      if (!testFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testFile.writeAsStringSync('Test content');
      }

      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenThrow(Exception('Upload failed'));

      // Act
      final result = await fileRepository.uploadFile(
        testFile,
        testFileName,
        testContentType,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to upload file'));

      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
      verifyNoMoreInteractions(mockAuthAdapter);
    });
  });

  group('deleteFile', () {
    test('should return Right(null) when file is deleted successfully',
        () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => testFileUrl);
      when(mockStorageAdapter.listFiles('files/$testUserId'))
          .thenAnswer((_) async => [mockFileRef]);
      when(mockFileRef.getMetadata()).thenAnswer((_) async => mockMetadata);
      when(mockStorageAdapter.deleteFile('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => {});

      // Act
      final result = await fileRepository.deleteFile(testFileId);

      // Assert
      expect(result.isRight, true);

      verify(mockAuthAdapter.getCurrentUser())
          .called(2); // Called for getFileById and deleteFile
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
      verify(mockStorageAdapter.listFiles('files/$testUserId'));
      verify(mockFileRef.getMetadata());
      verify(mockStorageAdapter.deleteFile('files/$testUserId/$testFileId'));
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await fileRepository.deleteFile(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'User not authenticated');

      verify(mockAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockAuthAdapter);
      verifyNoMoreInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when file is not found', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenThrow(Exception('File not found'));

      // Act
      final result = await fileRepository.deleteFile(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());

      verify(mockAuthAdapter.getCurrentUser());
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
      verifyNoMoreInteractions(mockAuthAdapter);
    });
  });

  group('shareFile', () {
    test('should return file URL when sharing is successful', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => testFileUrl);
      when(mockStorageAdapter.listFiles('files/$testUserId'))
          .thenAnswer((_) async => [mockFileRef]);
      when(mockFileRef.getMetadata()).thenAnswer((_) async => mockMetadata);

      // Act
      final result = await fileRepository.shareFile(testFileId);

      // Assert
      expect(result.isRight, true);
      expect(result.right, testFileUrl);

      verify(mockAuthAdapter.getCurrentUser());
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
      verify(mockStorageAdapter.listFiles('files/$testUserId'));
      verify(mockFileRef.getMetadata());
    });

    test('should return FileOperationFailure when file is not found', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenThrow(Exception('File not found'));

      // Act
      final result = await fileRepository.shareFile(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());

      verify(mockAuthAdapter.getCurrentUser());
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
    });
  });

  group('getFileById', () {
    test('should return file when it exists', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => testFileUrl);
      when(mockStorageAdapter.listFiles('files/$testUserId'))
          .thenAnswer((_) async => [mockFileRef]);
      when(mockFileRef.getMetadata()).thenAnswer((_) async => mockMetadata);

      // Act
      final result = await fileRepository.getFileById(testFileId);

      // Assert
      expect(result.isRight, true);
      expect(result.right.id, testFileId);
      expect(result.right.url, testFileUrl);
      expect(result.right.contentType, testContentType);

      verify(mockAuthAdapter.getCurrentUser());
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
      verify(mockStorageAdapter.listFiles('files/$testUserId'));
      verify(mockFileRef.getMetadata());
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(null);

      // Act
      final result = await fileRepository.getFileById(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<AuthFailure>());
      expect(result.left.message, 'User not authenticated');

      verify(mockAuthAdapter.getCurrentUser());
      verifyNoMoreInteractions(mockAuthAdapter);
      verifyNoMoreInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when file is not found', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'))
          .thenThrow(Exception('File not found'));

      // Act
      final result = await fileRepository.getFileById(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, 'File not found: $testFileId');

      verify(mockAuthAdapter.getCurrentUser());
      verify(
          mockStorageAdapter.getDownloadUrl('files/$testUserId/$testFileId'));
    });
  });
}
