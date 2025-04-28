import 'package:equatable/equatable.dart';
import '../../../domain/entities/file_item.dart';

abstract class FileListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileListInitial extends FileListState {}

class FileListLoading extends FileListState {}

class FileListLoaded extends FileListState {
  final List<FileItem> files;

  FileListLoaded(this.files);

  @override
  List<Object?> get props => [files];
}

class FileListError extends FileListState {
  final String message;

  FileListError(this.message);

  @override
  List<Object?> get props => [message];
}
