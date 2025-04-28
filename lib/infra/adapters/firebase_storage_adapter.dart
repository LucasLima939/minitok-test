import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

/// Firebase Storage adapter interface
abstract class FirebaseStorageAdapter {
  /// Upload a file to Firebase Storage
  /// Returns the download URL
  Future<String> uploadFile({
    required File file,
    required String path,
    required String fileName,
  });

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String filePath);

  /// Get download URL for a file
  Future<String> getDownloadUrl(String filePath);

  /// List files in a directory
  Future<List<firebase_storage.Reference>> listFiles(String path);
}

/// Implementation of Firebase Storage adapter
class FirebaseStorageAdapterImpl implements FirebaseStorageAdapter {
  final firebase_storage.FirebaseStorage _firebaseStorage;

  FirebaseStorageAdapterImpl({
    firebase_storage.FirebaseStorage? firebaseStorage,
  }) : _firebaseStorage =
            firebaseStorage ?? firebase_storage.FirebaseStorage.instance;

  @override
  Future<String> uploadFile({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child('$path/$fileName');
      final uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() => null);
      return await ref.getDownloadURL();
    } on firebase_storage.FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: You do not have permission to upload files. Please check your Firebase security rules.');
      } else {
        throw Exception('Failed to upload file: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  @override
  Future<void> deleteFile(String filePath) async {
    try {
      final ref = _firebaseStorage.ref().child(filePath);
      await ref.delete();
    } on firebase_storage.FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: You do not have permission to delete this file. Please check your Firebase security rules.');
      } else {
        throw Exception('Failed to delete file: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  @override
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _firebaseStorage.ref().child(filePath);
      return await ref.getDownloadURL();
    } on firebase_storage.FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: You do not have permission to access this file. Please check your Firebase security rules.');
      } else if (e.code == 'object-not-found') {
        throw Exception('File not found: The requested file does not exist');
      } else {
        throw Exception('Failed to get download URL: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  @override
  Future<List<firebase_storage.Reference>> listFiles(String path) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      final result = await ref.listAll();
      return result.items;
    } on firebase_storage.FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: You do not have permission to list files. Please check your Firebase security rules.');
      } else if (e.code == 'object-not-found') {
        // If the directory doesn't exist yet, return an empty list instead of throwing
        return [];
      } else {
        throw Exception('Failed to list files: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
