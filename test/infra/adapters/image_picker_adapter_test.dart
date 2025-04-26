import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minitok_test/infra/adapters/image_picker_adapter.dart';

// Generate mocks for ImagePicker
@GenerateMocks([ImagePicker, XFile])
import 'image_picker_adapter_test.mocks.dart';

void main() {
  late ImagePickerAdapterImpl imagePickerAdapter;
  late MockImagePicker mockImagePicker;
  late MockXFile mockXFile;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockXFile = MockXFile();
    imagePickerAdapter = ImagePickerAdapterImpl(imagePicker: mockImagePicker);

    // Common setup
    when(mockXFile.path).thenReturn('/path/to/image.jpg');
  });

  group('ImagePickerAdapter', () {
    test('pickImageFromGallery should return a File when image is picked',
        () async {
      // Arrange
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      )).thenAnswer((_) async => mockXFile);

      // Act
      final result = await imagePickerAdapter.pickImageFromGallery();

      // Assert
      expect(result, isA<File>());
      expect(result?.path, equals('/path/to/image.jpg'));
      verify(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      )).called(1);
    });

    test('pickImageFromGallery should return null when no image is picked',
        () async {
      // Arrange
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      )).thenAnswer((_) async => null);

      // Act
      final result = await imagePickerAdapter.pickImageFromGallery();

      // Assert
      expect(result, isNull);
      verify(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      )).called(1);
    });

    test('pickImageFromCamera should return a File when image is picked',
        () async {
      // Arrange
      when(mockImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      )).thenAnswer((_) async => mockXFile);

      // Act
      final result = await imagePickerAdapter.pickImageFromCamera();

      // Assert
      expect(result, isA<File>());
      expect(result?.path, equals('/path/to/image.jpg'));
      verify(mockImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      )).called(1);
    });

    test('pickImageFromCamera should return null when no image is picked',
        () async {
      // Arrange
      when(mockImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      )).thenAnswer((_) async => null);

      // Act
      final result = await imagePickerAdapter.pickImageFromCamera();

      // Assert
      expect(result, isNull);
      verify(mockImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      )).called(1);
    });

    test('pickImageFromGallery should throw exception when ImagePicker throws',
        () async {
      // Arrange
      final exception = Exception('Failed to pick image');
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => imagePickerAdapter.pickImageFromGallery(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
