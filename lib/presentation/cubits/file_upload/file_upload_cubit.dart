import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../../../domain/repositories/file_repository.dart';
import '../../../infra/adapters/image_picker_adapter.dart';
import '../../../infra/adapters/file_picker_adapter.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final FileRepository _fileRepository;
  final ImagePickerAdapter _imagePickerAdapter;
  final FilePickerAdapter _filePickerAdapter;

  FileUploadCubit(
    this._fileRepository, {
    ImagePickerAdapter? imagePickerAdapter,
    FilePickerAdapter? filePickerAdapter,
  })  : _imagePickerAdapter = imagePickerAdapter ?? ImagePickerAdapterImpl(),
        _filePickerAdapter = filePickerAdapter ?? FilePickerAdapterImpl(),
        super(FileUploadInitial());

  Future<void> uploadFile(File file, {String? customFileName}) async {
    try {
      // Reset to initial state and then emit loading
      emit(FileUploadLoading());

      // Determine file name - use custom name if provided or get from file path
      final fileName = customFileName ?? path.basename(file.path);

      // Determine content type from file extension
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Start file upload
      final result = await _fileRepository.uploadFile(
        file,
        fileName,
        mimeType,
      );

      result.fold(
        (failure) => emit(FileUploadFailure(failure.message)),
        (fileItem) => emit(FileUploadSuccess(fileItem)),
      );
    } catch (e) {
      emit(FileUploadFailure('Failed to upload file: ${e.toString()}'));
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final file = await _imagePickerAdapter.pickImageFromGallery();

      if (file != null) {
        await uploadFile(file);
      }
    } catch (e) {
      emit(FileUploadFailure('Error picking image: ${e.toString()}'));
    }
  }

  Future<void> pickAndUploadDocument() async {
    try {
      final file = await _filePickerAdapter.pickFile();

      if (file != null) {
        await uploadFile(file);
      }
    } catch (e) {
      emit(FileUploadFailure('Error picking document: ${e.toString()}'));
    }
  }

  void reset() {
    emit(FileUploadInitial());
  }
}
