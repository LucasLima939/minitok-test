import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../../domain/entities/file_item.dart';

abstract class FileDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class FileDetailsInitial extends FileDetailsState {}

// Download states
class FileDownloadLoading extends FileDetailsState {
  final double progress;

  FileDownloadLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

class FileDownloadSuccess extends FileDetailsState {
  final File file;

  FileDownloadSuccess(this.file);

  @override
  List<Object?> get props => [file];
}

// Share states
class FileShareLoading extends FileDetailsState {}

class FileShareSuccess extends FileDetailsState {
  final String shareUrl;

  FileShareSuccess(this.shareUrl);

  @override
  List<Object?> get props => [shareUrl];
}

// Delete states
class FileDeleteLoading extends FileDetailsState {}

class FileDeleteSuccess extends FileDetailsState {
  final FileItem deletedFile;

  FileDeleteSuccess(this.deletedFile);

  @override
  List<Object?> get props => [deletedFile];
}

// Error state for all operations
class FileOperationFailure extends FileDetailsState {
  final String operation;
  final String message;

  FileOperationFailure({
    required this.operation,
    required this.message,
  });

  @override
  List<Object?> get props => [operation, message];
}
