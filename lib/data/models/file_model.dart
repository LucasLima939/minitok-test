// FileModel implementation of the FileItem entity
// This model handles serialization/deserialization and extends the domain entity

import '../../domain/entities/file_item.dart';

class FileModel extends FileItem {
  const FileModel({
    required super.id,
    required super.name,
    required super.url,
    required super.contentType,
    required super.size,
    required super.createdAt,
    super.ownerId,
  });

  // Create a FileModel from a JSON map
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      contentType: json['contentType'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownerId: json['ownerId'] as String?,
    );
  }

  // Convert FileModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'contentType': contentType,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
    };
  }

  // Create a FileModel from a Firebase Storage file
  factory FileModel.fromFirebaseStorage(
    String id,
    String name,
    String url,
    String contentType,
    int size,
    DateTime createdAt,
    String? ownerId,
  ) {
    return FileModel(
      id: id,
      name: name,
      url: url,
      contentType: contentType,
      size: size,
      createdAt: createdAt,
      ownerId: ownerId,
    );
  }
}
