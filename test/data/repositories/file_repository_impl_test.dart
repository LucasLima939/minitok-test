import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:minitok_test/core/error/failures.dart';
import 'package:minitok_test/data/repositories/file_repository_impl.dart';
import 'package:minitok_test/domain/entities/file_item.dart';
import 'package:minitok_test/infra/adapters/firebase_storage_adapter.dart';
import 'package:minitok_test/infra/adapters/firebase_auth_adapter.dart';
import 'package:minitok_test/infra/adapters/share_plus_adapter.dart';
import 'package:minitok_test/infra/adapters/http_client_adapter.dart';
import 'package:minitok_test/infra/adapters/temp_directory_adapter.dart';
import 'package:minitok_test/infra/adapters/image_picker_adapter.dart';
import 'package:minitok_test/infra/adapters/file_picker_adapter.dart';

// Generate mocks for adapters
@GenerateMocks([
  FirebaseStorageAdapter,
  FirebaseAuthAdapter,
  SharePlusAdapter,
  HttpClientAdapter,
  TempDirectoryAdapter,
  ImagePickerAdapter,
  FilePickerAdapter,
  firebase_storage.FullMetadata,
  firebase_storage.Reference,
  firebase_auth.User,
])
import 'file_repository_impl_test.mocks.dart';

void main() {
  late MockFirebaseStorageAdapter mockStorageAdapter;
  late MockFirebaseAuthAdapter mockAuthAdapter;
  late MockSharePlusAdapter mockSharePlusAdapter;
  late MockHttpClientAdapter mockHttpClientAdapter;
  late MockTempDirectoryAdapter mockTempDirectoryAdapter;
  late MockImagePickerAdapter mockImagePickerAdapter;
  late MockFilePickerAdapter mockFilePickerAdapter;
  late FileRepositoryImpl fileRepository;
  late MockUser mockUser;
  late MockReference mockFileRef;
  late MockFullMetadata mockMetadata;
  late FileItem mockFileItem;

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
    mockSharePlusAdapter = MockSharePlusAdapter();
    mockHttpClientAdapter = MockHttpClientAdapter();
    mockTempDirectoryAdapter = MockTempDirectoryAdapter();
    mockImagePickerAdapter = MockImagePickerAdapter();
    mockFilePickerAdapter = MockFilePickerAdapter();
    fileRepository = FileRepositoryImpl(
      mockStorageAdapter,
      mockAuthAdapter,
      mockSharePlusAdapter,
      mockHttpClientAdapter,
      mockTempDirectoryAdapter,
      mockImagePickerAdapter,
      mockFilePickerAdapter,
    );

    // Create mock file item
    mockFileItem = FileItem(
      id: testFileId,
      name: testFileName,
      url: testFileUrl,
      contentType: testContentType,
      size: 1024,
      createdAt: DateTime.now(),
      ownerId: testUserId,
    );

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
      when(mockStorageAdapter.deleteFile('files/$testUserId/$testFileId'))
          .thenAnswer((_) async => {});

      // Act
      final result = await fileRepository.deleteFile(testFileId);

      // Assert
      expect(result.isRight, true);

      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.deleteFile('files/$testUserId/$testFileId'));
    });

    test('should return FileOperationFailure when deletion fails', () async {
      // Arrange
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.deleteFile('files/$testUserId/$testFileId'))
          .thenThrow(Exception('File not found'));

      // Act
      final result = await fileRepository.deleteFile(testFileId);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to delete file'));
    });
  });

  group('shareFile', () {
    final testLocalFile = File('test/fixtures/downloaded.pdf');

    test('should return file URL when sharing is successful', () async {
      // Arrange
      // Setup mock file item
      final mockFileItem = FileItem(
        id: testFileId,
        name: testFileName,
        url: testFileUrl,
        contentType: testContentType,
        size: 1024,
        createdAt: DateTime.now(),
        ownerId: testUserId,
      );

      // Setup authentication
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);

      // Setup successful download
      when(mockTempDirectoryAdapter.createTempFile(testFileName))
          .thenReturn(testLocalFile);
      when(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile))
          .thenAnswer((_) async => {});

      // Setup successful share
      when(mockSharePlusAdapter.shareFile(
        testLocalFile,
        text: testFileName,
      )).thenAnswer((_) async => {});

      // Act
      final result = await fileRepository.shareFile(mockFileItem);

      // Assert
      expect(result.isRight, true);
      expect(result.right, testFileUrl);
    });

    test('should return FileOperationFailure when sharing fails', () async {
      // Arrange
      // Setup mock file item
      final mockFileItem = FileItem(
        id: testFileId,
        name: testFileName,
        url: testFileUrl,
        contentType: testContentType,
        size: 1024,
        createdAt: DateTime.now(),
        ownerId: testUserId,
      );

      // Setup authentication
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);

      // Setup successful download
      when(mockTempDirectoryAdapter.createTempFile(testFileName))
          .thenReturn(testLocalFile);
      when(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile))
          .thenAnswer((_) async => {});

      // Setup failed share
      when(mockSharePlusAdapter.shareFile(
        testLocalFile,
        text: testFileName,
      )).thenThrow(Exception('Sharing failed'));

      // Act
      final result = await fileRepository.shareFile(mockFileItem);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to share file'));
    });

    test('should return FileOperationFailure when download fails', () async {
      // Arrange
      // Setup mock file item
      final mockFileItem = FileItem(
        id: testFileId,
        name: testFileName,
        url: testFileUrl,
        contentType: testContentType,
        size: 1024,
        createdAt: DateTime.now(),
        ownerId: testUserId,
      );

      // Setup authentication
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);

      // Setup failed download
      when(mockTempDirectoryAdapter.createTempFile(testFileName))
          .thenReturn(testLocalFile);
      when(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile))
          .thenThrow(Exception('Download failed'));

      // Act
      final result = await fileRepository.shareFile(mockFileItem);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to share file'));
    });
  });

  group('downloadFile', () {
    test('should return downloaded file when successful', () async {
      // Arrange
      final testLocalFile = File('test/fixtures/downloaded.pdf');

      when(mockTempDirectoryAdapter.createTempFile(testFileName))
          .thenReturn(testLocalFile);
      when(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile))
          .thenAnswer((_) async => {});

      // Act
      final result = await fileRepository.downloadFile(mockFileItem);

      // Assert
      expect(result.isRight, true);
      expect(result.right, testLocalFile);

      verify(mockTempDirectoryAdapter.createTempFile(testFileName));
      verify(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile));
    });

    test('should return FileOperationFailure when download fails', () async {
      // Arrange
      final testLocalFile = File('test/fixtures/downloaded.pdf');

      when(mockTempDirectoryAdapter.createTempFile(testFileName))
          .thenReturn(testLocalFile);
      when(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile))
          .thenThrow(Exception('Download failed'));

      // Act
      final result = await fileRepository.downloadFile(mockFileItem);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to download file'));

      verify(mockTempDirectoryAdapter.createTempFile(testFileName));
      verify(mockHttpClientAdapter.downloadFile(testFileUrl, testLocalFile));
    });
  });

  group('pickAndUploadImage', () {
    test('should return uploaded image when successful', () async {
      // Arrange
      final testImageFile = File('test/fixtures/test_image.jpg');

      // Create a temporary file for testing if it doesn't exist
      if (!testImageFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testImageFile.writeAsStringSync('Test image content');
      }

      when(mockImagePickerAdapter.pickImageFromGallery())
          .thenAnswer((_) async => testImageFile);
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => testFileUrl);

      // Act
      final result = await fileRepository.pickAndUploadImage();

      // Assert
      expect(result.isRight, true);
      expect(result.right.url, testFileUrl);

      verify(mockImagePickerAdapter.pickImageFromGallery());
      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
    });

    test('should return FileOperationFailure when no image is selected',
        () async {
      // Arrange
      when(mockImagePickerAdapter.pickImageFromGallery())
          .thenAnswer((_) async => null);

      // Act
      final result = await fileRepository.pickAndUploadImage();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, 'No image selected');

      verify(mockImagePickerAdapter.pickImageFromGallery());
      verifyZeroInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when image picker throws',
        () async {
      // Arrange
      when(mockImagePickerAdapter.pickImageFromGallery())
          .thenThrow(Exception('Failed to pick image'));

      // Act
      final result = await fileRepository.pickAndUploadImage();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Error picking image'));

      verify(mockImagePickerAdapter.pickImageFromGallery());
      verifyZeroInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when upload fails', () async {
      // Arrange
      final testImageFile = File('test/fixtures/test_image.jpg');

      // Create a temporary file for testing if it doesn't exist
      if (!testImageFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testImageFile.writeAsStringSync('Test image content');
      }

      when(mockImagePickerAdapter.pickImageFromGallery())
          .thenAnswer((_) async => testImageFile);
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenThrow(Exception('Upload failed'));

      // Act
      final result = await fileRepository.pickAndUploadImage();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to upload file'));

      verify(mockImagePickerAdapter.pickImageFromGallery());
      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
    });
  });

  group('pickAndUploadDocument', () {
    test('should return uploaded document when successful', () async {
      // Arrange
      final testDocFile = File('test/fixtures/test_doc.pdf');

      // Create a temporary file for testing if it doesn't exist
      if (!testDocFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testDocFile.writeAsStringSync('Test document content');
      }

      when(mockFilePickerAdapter.pickFile())
          .thenAnswer((_) async => testDocFile);
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenAnswer((_) async => testFileUrl);

      // Act
      final result = await fileRepository.pickAndUploadDocument();

      // Assert
      expect(result.isRight, true);
      expect(result.right.url, testFileUrl);

      verify(mockFilePickerAdapter.pickFile());
      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
    });

    test('should return FileOperationFailure when no document is selected',
        () async {
      // Arrange
      when(mockFilePickerAdapter.pickFile()).thenAnswer((_) async => null);

      // Act
      final result = await fileRepository.pickAndUploadDocument();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, 'No document selected');

      verify(mockFilePickerAdapter.pickFile());
      verifyZeroInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when file picker throws',
        () async {
      // Arrange
      when(mockFilePickerAdapter.pickFile())
          .thenThrow(Exception('Failed to pick document'));

      // Act
      final result = await fileRepository.pickAndUploadDocument();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Error picking document'));

      verify(mockFilePickerAdapter.pickFile());
      verifyZeroInteractions(mockStorageAdapter);
    });

    test('should return FileOperationFailure when upload fails', () async {
      // Arrange
      final testDocFile = File('test/fixtures/test_doc.pdf');

      // Create a temporary file for testing if it doesn't exist
      if (!testDocFile.existsSync()) {
        Directory('test/fixtures').createSync(recursive: true);
        testDocFile.writeAsStringSync('Test document content');
      }

      when(mockFilePickerAdapter.pickFile())
          .thenAnswer((_) async => testDocFile);
      when(mockAuthAdapter.getCurrentUser()).thenReturn(mockUser);
      when(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      )).thenThrow(Exception('Upload failed'));

      // Act
      final result = await fileRepository.pickAndUploadDocument();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, isA<FileOperationFailure>());
      expect(result.left.message, contains('Failed to upload file'));

      verify(mockFilePickerAdapter.pickFile());
      verify(mockAuthAdapter.getCurrentUser());
      verify(mockStorageAdapter.uploadFile(
        file: anyNamed('file'),
        path: anyNamed('path'),
        fileName: anyNamed('fileName'),
      ));
    });
  });
}
