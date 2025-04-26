// FileItem entity class
// Represents a file in the domain layer

class FileItem {
  final String id;
  final String name;
  final String url;
  final String contentType;
  final int size;
  final DateTime createdAt;
  final String? ownerId;

  const FileItem({
    required this.id,
    required this.name,
    required this.url,
    required this.contentType,
    required this.size,
    required this.createdAt,
    this.ownerId,
  });
}
