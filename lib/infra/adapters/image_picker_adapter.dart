import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// ImagePicker adapter interface
abstract class ImagePickerAdapter {
  /// Pick an image from gallery
  Future<File?> pickImageFromGallery();

  /// Pick an image from camera
  Future<File?> pickImageFromCamera();
}

/// Implementation of ImagePicker adapter
class ImagePickerAdapterImpl implements ImagePickerAdapter {
  final ImagePicker _imagePicker;

  ImagePickerAdapterImpl({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  @override
  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }
}
