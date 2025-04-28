import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/file_item.dart';
import '../../../domain/repositories/file_repository.dart';
import 'file_details_state.dart';

class FileDetailsCubit extends Cubit<FileDetailsState> {
  final FileRepository _fileRepository;

  FileDetailsCubit(this._fileRepository) : super(FileDetailsInitial());

  /// Download a file
  Future<void> downloadFile(FileItem file) async {
    try {
      emit(FileDownloadLoading());

      final result = await _fileRepository.downloadFile(file);

      result.fold(
        (failure) => emit(FileOperationFailure(
          operation: 'download',
          message: failure.message,
        )),
        (downloadedFile) => emit(FileDownloadSuccess(downloadedFile)),
      );
    } catch (e) {
      emit(FileOperationFailure(
        operation: 'download',
        message: 'Failed to download file: ${e.toString()}',
      ));
    }
  }

  /// Share a file
  Future<void> shareFile(FileItem file) async {
    try {
      emit(FileShareLoading());

      final result = await _fileRepository.shareFile(file);

      result.fold(
        (failure) => emit(FileOperationFailure(
          operation: 'share',
          message: failure.message,
        )),
        (_) => emit(FileShareSuccess(file.url)),
      );
    } catch (e) {
      emit(FileOperationFailure(
        operation: 'share',
        message: 'Failed to share file: ${e.toString()}',
      ));
    }
  }

  /// Delete a file
  Future<void> deleteFile(FileItem file) async {
    try {
      emit(FileDeleteLoading());

      final result = await _fileRepository.deleteFile(file.id);

      result.fold(
        (failure) => emit(FileOperationFailure(
          operation: 'delete',
          message: failure.message,
        )),
        (_) => emit(FileDeleteSuccess(file)),
      );
    } catch (e) {
      emit(FileOperationFailure(
        operation: 'delete',
        message: 'Failed to delete file: ${e.toString()}',
      ));
    }
  }

  /// Reset the state to initial
  void reset() {
    emit(FileDetailsInitial());
  }
}
