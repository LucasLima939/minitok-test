import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// FilePicker adapter interface
abstract class FilePickerAdapter {
  /// Pick a single file
  Future<File?> pickFile({List<String>? allowedExtensions});
}

/// Implementation of FilePicker adapter
class FilePickerAdapterImpl implements FilePickerAdapter {
  final FilePicker _filePicker;

  FilePickerAdapterImpl({FilePicker? filePicker})
      : _filePicker = filePicker ?? FilePicker.platform;

  @override
  Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await _filePicker.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }
}
