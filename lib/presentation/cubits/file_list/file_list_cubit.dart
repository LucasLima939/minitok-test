import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/file_repository.dart';
import 'file_list_state.dart';

class FileListCubit extends Cubit<FileListState> {
  final FileRepository _fileRepository;

  FileListCubit(this._fileRepository) : super(FileListInitial());

  Future<void> loadFiles() async {
    emit(FileListLoading());

    final result = await _fileRepository.getFiles();

    result.fold(
      (failure) => emit(FileListError(failure.message)),
      (files) => emit(FileListLoaded(files)),
    );
  }

  // Method to reload files (can be called when user pulls to refresh)
  Future<void> refreshFiles() async {
    // If already in loading state, don't reload
    if (state is FileListLoading) return;

    // Keep the current state visible while loading in background
    final currentState = state;

    final result = await _fileRepository.getFiles();

    // Only update if we're still in the same state to avoid UI flickering
    if (state == currentState) {
      result.fold(
        (failure) => emit(FileListError(failure.message)),
        (files) => emit(FileListLoaded(files)),
      );
    }
  }
}
