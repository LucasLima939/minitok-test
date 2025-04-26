import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:minitok_test/infra/adapters/firebase_storage_adapter.dart';

// Generate mocks for Firebase Storage
@GenerateMocks([
  firebase_storage.FirebaseStorage,
  firebase_storage.Reference,
  firebase_storage.UploadTask,
  firebase_storage.TaskSnapshot,
  firebase_storage.ListResult,
  File,
])
import 'firebase_storage_adapter_test.mocks.dart';

void main() {
  late FirebaseStorageAdapterImpl firebaseStorageAdapter;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockStorageReference;
  late MockFile mockFile;

  setUp(() {
    mockFirebaseStorage = MockFirebaseStorage();
    mockStorageReference = MockReference();
    mockFile = MockFile();

    // Configure storage
    when(mockFirebaseStorage.ref()).thenReturn(mockStorageReference);

    firebaseStorageAdapter = FirebaseStorageAdapterImpl(
      firebaseStorage: mockFirebaseStorage,
    );
  });

  group('FirebaseStorageAdapter', () {
    test('uploadFile should upload file and return download URL', () async {
      // Arrange
      const filePath = 'path/to/file';
      const fileName = 'test_file.jpg';
      const downloadUrl = 'https://example.com/files/test_file.jpg';

      final mockUploadTask = MockUploadTask();
      final mockTaskSnapshot = MockTaskSnapshot();
      final mockChildReference = MockReference();

      // Setup reference chain
      when(mockStorageReference.child('$filePath/$fileName'))
          .thenReturn(mockChildReference);
      when(mockChildReference.putFile(any)).thenAnswer((_) => mockUploadTask);
      when(mockUploadTask.whenComplete(any))
          .thenAnswer((_) async => mockTaskSnapshot);
      when(mockChildReference.getDownloadURL())
          .thenAnswer((_) async => downloadUrl);

      // Act
      final result = await firebaseStorageAdapter.uploadFile(
        file: mockFile,
        path: filePath,
        fileName: fileName,
      );

      // Assert
      expect(result, equals(downloadUrl));
      verify(mockStorageReference.child('$filePath/$fileName')).called(1);
      verify(mockChildReference.putFile(any)).called(1);
      verify(mockChildReference.getDownloadURL()).called(1);
    });

    test('deleteFile should call delete on the reference', () async {
      // Arrange
      const filePath = 'path/to/file.jpg';
      final mockChildReference = MockReference();

      // Setup mock for this test
      when(mockStorageReference.child(filePath)).thenReturn(mockChildReference);
      when(mockChildReference.delete()).thenAnswer((_) async => {});

      // Act
      await firebaseStorageAdapter.deleteFile(filePath);

      // Assert
      verify(mockStorageReference.child(filePath)).called(1);
      verify(mockChildReference.delete()).called(1);
    });

    test('getDownloadUrl should return the download URL', () async {
      // Arrange
      const filePath = 'path/to/file.jpg';
      const downloadUrl = 'https://example.com/files/file.jpg';
      final mockChildReference = MockReference();

      // Setup mock for this test
      when(mockStorageReference.child(filePath)).thenReturn(mockChildReference);
      when(mockChildReference.getDownloadURL())
          .thenAnswer((_) async => downloadUrl);

      // Act
      final result = await firebaseStorageAdapter.getDownloadUrl(filePath);

      // Assert
      expect(result, equals(downloadUrl));
      verify(mockStorageReference.child(filePath)).called(1);
      verify(mockChildReference.getDownloadURL()).called(1);
    });

    test('listFiles should return list of references', () async {
      // Arrange
      const path = 'files';
      final mockListResult = MockListResult();
      final mockReferences = [MockReference(), MockReference()];
      final mockChildReference = MockReference();

      // Setup mock for this test
      when(mockStorageReference.child(path)).thenReturn(mockChildReference);
      when(mockChildReference.listAll())
          .thenAnswer((_) async => mockListResult);
      when(mockListResult.items).thenReturn(mockReferences);

      // Act
      final result = await firebaseStorageAdapter.listFiles(path);

      // Assert
      expect(result, equals(mockReferences));
      verify(mockStorageReference.child(path)).called(1);
      verify(mockChildReference.listAll()).called(1);
    });

    test('uploadFile should throw exception when upload fails', () async {
      // Arrange
      const filePath = 'path/to/file';
      const fileName = 'test_file.jpg';
      final exception = Exception('Upload failed');
      final mockChildReference = MockReference();

      // Setup mock for this test
      when(mockStorageReference.child('$filePath/$fileName'))
          .thenReturn(mockChildReference);
      when(mockChildReference.putFile(any)).thenThrow(exception);

      // Act & Assert
      expect(
        () => firebaseStorageAdapter.uploadFile(
          file: mockFile,
          path: filePath,
          fileName: fileName,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
