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

class FileRepositoryImpl implements FileRepository {
  final FirebaseStorageAdapter _storageAdapter;
  final FirebaseAuthAdapter _authAdapter;
  final Uuid _uuid = const Uuid();

  FileRepositoryImpl(this._storageAdapter, this._authAdapter);

  @override
  Future<Either<Failure, List<FileItem>>> getFiles() async {
    try {
      final currentUser = _authAdapter.getCurrentUser();

      if (currentUser == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final userId = currentUser.uid;
      final userFilesPath = 'files/$userId';

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
            ownerId: userId,
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
      final currentUser = _authAdapter.getCurrentUser();

      if (currentUser == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final userId = currentUser.uid;
      final fileId = _uuid.v4();
      final fileExtension = path.extension(fileName);
      final uniqueFileName = '$fileId$fileExtension';
      final userFilesPath = 'files/$userId';

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
        ownerId: userId,
      );

      return Right(fileItem);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to upload file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> downloadFile(String fileId) async {
    try {
      final fileItem = await getFileById(fileId);

      if (fileItem.isLeft) {
        return Left(fileItem.left);
      }

      final item = fileItem.right;
      final tempDir = Directory.systemTemp;
      final localFile = File('${tempDir.path}/${item.name}');

      // Download the file from the URL
      // This is a simplified version - in a real app, you'd use http or dio to download the file
      final request = await HttpClient().getUrl(Uri.parse(item.url));
      final response = await request.close();
      await response.pipe(localFile.openWrite());

      return Right(localFile);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to download file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String fileId) async {
    try {
      final fileItem = await getFileById(fileId);

      if (fileItem.isLeft) {
        return Left(fileItem.left);
      }

      final currentUser = _authAdapter.getCurrentUser();

      if (currentUser == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final userId = currentUser.uid;
      final filePath = 'files/$userId/$fileId';

      await _storageAdapter.deleteFile(filePath);

      return const Right(null);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to delete file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> shareFile(String fileId) async {
    try {
      final fileItem = await getFileById(fileId);

      if (fileItem.isLeft) {
        return Left(fileItem.left);
      }

      // In a real implementation, you might generate a sharing token or use Firebase Dynamic Links
      // For simplicity, we'll just return the download URL
      return Right(fileItem.right.url);
    } catch (e) {
      return Left(FileOperationFailure(
          message: 'Failed to share file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileItem>> getFileById(String fileId) async {
    try {
      final currentUser = _authAdapter.getCurrentUser();

      if (currentUser == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final userId = currentUser.uid;
      final filePath = 'files/$userId/$fileId';

      try {
        final downloadUrl = await _storageAdapter.getDownloadUrl(filePath);

        // Find the file by listing files and filtering
        final fileReferences = await _storageAdapter.listFiles('files/$userId');
        final fileRef = fileReferences.firstWhere(
          (ref) => ref.name == fileId || ref.name.startsWith('$fileId.'),
          orElse: () => throw Exception('File not found'),
        );

        final metadata = await fileRef.getMetadata();

        final fileItem = FileModel(
          id: fileId,
          name: path.basename(metadata.name),
          url: downloadUrl,
          contentType: metadata.contentType ?? 'application/octet-stream',
          size: metadata.size ?? 0,
          createdAt: metadata.timeCreated ?? DateTime.now(),
          ownerId: userId,
        );

        return Right(fileItem);
      } catch (e) {
        return Left(FileOperationFailure(message: 'File not found: $fileId'));
      }
    } catch (e) {
      return Left(
          FileOperationFailure(message: 'Failed to get file: ${e.toString()}'));
    }
  }
}
