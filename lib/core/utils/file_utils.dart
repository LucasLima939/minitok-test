/// Utility functions for handling files
class FileUtils {
  /// Determines file type from content type (MIME type)
  static String getFileType(String contentType) {
    if (contentType.startsWith('image/')) return 'image';
    if (contentType.startsWith('application/pdf')) return 'pdf';
    if (contentType.contains('spreadsheet') || contentType.contains('excel')) {
      return 'spreadsheet';
    }
    if (contentType.contains('presentation') ||
        contentType.contains('powerpoint')) {
      return 'presentation';
    }
    if (contentType.contains('document') || contentType.contains('word')) {
      return 'document';
    }
    return 'file';
  }
}
