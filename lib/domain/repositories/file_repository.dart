// Interface for file repository
// This defines the contract that any file repository implementation must follow

import 'package:either_dart/either.dart';
import 'dart:io';
import '../entities/file_item.dart';
import '../../core/error/failures.dart';

abstract class FileRepository {
  /// Get all files for the current user
  /// Returns Either a Failure or a List of FileItem entities
  Future<Either<Failure, List<FileItem>>> getFiles();

  /// Upload a file for the current user
  /// Returns Either a Failure or the uploaded FileItem entity
  Future<Either<Failure, FileItem>> uploadFile(
    File file,
    String fileName,
    String contentType,
  );

  /// Download a file by its ID
  /// Returns Either a Failure or the downloaded File
  Future<Either<Failure, File>> downloadFile(FileItem fileItem);

  /// Delete a file by its ID
  /// Returns Either a Failure or void for success
  Future<Either<Failure, void>> deleteFile(String fileId);

  /// Share a file by its ID
  /// Returns Either a Failure or a sharing URL string
  Future<Either<Failure, String>> shareFile(FileItem fileItem);

  /// Pick an image from gallery and upload it
  /// Returns Either a Failure or the uploaded FileItem entity
  Future<Either<Failure, FileItem>> pickAndUploadImage();

  /// Pick a document and upload it
  /// Returns Either a Failure or the uploaded FileItem entity
  Future<Either<Failure, FileItem>> pickAndUploadDocument();
}
