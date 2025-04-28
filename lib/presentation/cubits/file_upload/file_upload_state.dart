import 'package:equatable/equatable.dart';
import '../../../domain/entities/file_item.dart';

abstract class FileUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileUploadInitial extends FileUploadState {}

class FileUploadLoading extends FileUploadState {
  final double progress;

  FileUploadLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class FileUploadSuccess extends FileUploadState {
  final FileItem file;

  FileUploadSuccess(this.file);

  @override
  List<Object?> get props => [file];
}

class FileUploadFailure extends FileUploadState {
  final String message;

  FileUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
