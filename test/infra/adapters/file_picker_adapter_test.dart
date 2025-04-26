import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:minitok_test/infra/adapters/file_picker_adapter.dart';

// Generate mocks for FilePicker classes
@GenerateMocks([FilePicker, FilePickerResult, PlatformFile])
import 'file_picker_adapter_test.mocks.dart';

void main() {
  late FilePickerAdapterImpl filePickerAdapter;
  late MockFilePicker mockFilePicker;
  late MockFilePickerResult mockFilePickerResult;
  late MockPlatformFile mockPlatformFile;

  setUp(() {
    mockFilePicker = MockFilePicker();
    mockFilePickerResult = MockFilePickerResult();
    mockPlatformFile = MockPlatformFile();
    filePickerAdapter = FilePickerAdapterImpl(filePicker: mockFilePicker);

    // Common setup
    when(mockPlatformFile.path).thenReturn('/path/to/file.pdf');
  });

  group('FilePickerAdapter', () {
    test('pickFile should return a File when file is picked', () async {
      // Arrange
      when(mockFilePicker.pickFiles(
        type: anyNamed('type'),
        allowedExtensions: anyNamed('allowedExtensions'),
      )).thenAnswer((_) async => mockFilePickerResult);

      when(mockFilePickerResult.files).thenReturn([mockPlatformFile]);

      // Act
      final result = await filePickerAdapter.pickFile();

      // Assert
      expect(result, isA<File>());
      expect(result?.path, equals('/path/to/file.pdf'));
      verify(mockFilePicker.pickFiles(
        type: FileType.any,
        allowedExtensions: null,
      )).called(1);
    });

    test(
        'pickFile should return a File when file is picked with allowed extensions',
        () async {
      // Arrange
      final allowedExtensions = ['pdf', 'doc', 'docx'];

      when(mockFilePicker.pickFiles(
        type: anyNamed('type'),
        allowedExtensions: anyNamed('allowedExtensions'),
      )).thenAnswer((_) async => mockFilePickerResult);

      when(mockFilePickerResult.files).thenReturn([mockPlatformFile]);

      // Act
      final result = await filePickerAdapter.pickFile(
          allowedExtensions: allowedExtensions);

      // Assert
      expect(result, isA<File>());
      expect(result?.path, equals('/path/to/file.pdf'));
      verify(mockFilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      )).called(1);
    });

    test('pickFile should return null when no file is picked', () async {
      // Arrange
      when(mockFilePicker.pickFiles(
        type: anyNamed('type'),
        allowedExtensions: anyNamed('allowedExtensions'),
      )).thenAnswer((_) async => null);

      // Act
      final result = await filePickerAdapter.pickFile();

      // Assert
      expect(result, isNull);
      verify(mockFilePicker.pickFiles(
        type: FileType.any,
        allowedExtensions: null,
      )).called(1);
    });

    test('pickFile should return null when file path is null', () async {
      // Arrange
      when(mockFilePicker.pickFiles(
        type: anyNamed('type'),
        allowedExtensions: anyNamed('allowedExtensions'),
      )).thenAnswer((_) async => mockFilePickerResult);

      when(mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(mockPlatformFile.path).thenReturn(null);

      // Act
      final result = await filePickerAdapter.pickFile();

      // Assert
      expect(result, isNull);
    });

    test('pickFile should throw exception when FilePicker throws', () async {
      // Arrange
      final exception = Exception('Failed to pick file');
      when(mockFilePicker.pickFiles(
        type: anyNamed('type'),
        allowedExtensions: anyNamed('allowedExtensions'),
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => filePickerAdapter.pickFile(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
