import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../../../domain/repositories/file_repository.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final FileRepository _fileRepository;

  FileUploadCubit(
    this._fileRepository,
  ) : super(FileUploadInitial());

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
      emit(FileUploadLoading());

      final result = await _fileRepository.pickAndUploadImage();

      result.fold(
        (failure) => emit(FileUploadFailure(failure.message)),
        (fileItem) => emit(FileUploadSuccess(fileItem)),
      );
    } catch (e) {
      emit(FileUploadFailure('Error picking image: ${e.toString()}'));
    }
  }

  Future<void> pickAndUploadDocument() async {
    try {
      emit(FileUploadLoading());

      final result = await _fileRepository.pickAndUploadDocument();

      result.fold(
        (failure) => emit(FileUploadFailure(failure.message)),
        (fileItem) => emit(FileUploadSuccess(fileItem)),
      );
    } catch (e) {
      emit(FileUploadFailure('Error picking document: ${e.toString()}'));
    }
  }

  void reset() {
    emit(FileUploadInitial());
  }
}
