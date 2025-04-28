import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/file_repository.dart';
import '../models/file_model.dart';
import '../../infra/adapters/firebase_storage_adapter.dart';
import '../../infra/adapters/firebase_auth_adapter.dart';
import '../../infra/adapters/share_plus_adapter.dart';
import '../../infra/adapters/http_client_adapter.dart';
import '../../infra/adapters/temp_directory_adapter.dart';

class FileRepositoryImpl implements FileRepository {
  final FirebaseStorageAdapter _storageAdapter;
  final FirebaseAuthAdapter _authAdapter;
  final SharePlusAdapter _sharePlusAdapter;
  final HttpClientAdapter _httpClientAdapter;
  final TempDirectoryAdapter _tempDirectoryAdapter;
  final Uuid _uuid = const Uuid();

  FileRepositoryImpl(
    this._storageAdapter,
    this._authAdapter,
    this._sharePlusAdapter,
    this._httpClientAdapter,
    this._tempDirectoryAdapter,
  );

  String get currentUserId => _authAdapter.getCurrentUser()?.uid ?? '';

  @override
  Future<Either<Failure, List<FileItem>>> getFiles() async {
    try {
      final userFilesPath = 'files/$currentUserId';

      final fileReferences = await _storageAdapter.listFiles(userFilesPath);
      final files = <FileModel>[];

      for (final fileRef in fileReferences) {
        final url = await _storageAdapter.getDownloadUrl(fileRef.fullPath);
        final metadata = await fileRef.getMetadata();

        files.add(
          FileModel(
            id: fileRef.name,
            name: path.basename(fileRef.name),
            url: url,
            contentType: metadata.contentType ?? 'application/octet-stream',
            size: metadata.size ?? 0,
            createdAt: metadata.timeCreated ?? DateTime.now(),
            ownerId: currentUserId,
          ),
        );
      }

      return Right(files);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to retrieve files: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileItem>> uploadFile(
      File file, String fileName, String contentType) async {
    try {
      final fileId = _uuid.v4();
      final fileExtension = path.extension(fileName);
      final uniqueFileName = '$fileId$fileExtension';
      final userFilesPath = 'files/$currentUserId';

      final downloadUrl = await _storageAdapter.uploadFile(
        file: file,
        path: userFilesPath,
        fileName: uniqueFileName,
      );

      final fileItem = FileModel(
        id: fileId,
        name: fileName,
        url: downloadUrl,
        contentType: contentType,
        size: await file.length(),
        createdAt: DateTime.now(),
        ownerId: currentUserId,
      );

      return Right(fileItem);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to upload file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> downloadFile(FileItem item) async {
    try {
      final localFile = _tempDirectoryAdapter.createTempFile(item.name);

      // Download the file from the URL using the adapter
      await _httpClientAdapter.downloadFile(item.url, localFile);

      return Right(localFile);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to download file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String fileId) async {
    try {
      final filePath = 'files/$currentUserId/$fileId';

      await _storageAdapter.deleteFile(filePath);

      return const Right(null);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to delete file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> shareFile(FileItem fileItem) async {
    try {
      final file = await downloadFile(fileItem);
      await _sharePlusAdapter.shareFile(
        file.right,
        text: fileItem.name,
      );
      return Right(fileItem.url);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to share file: ${e.toString()}'));
    }
  }
}
