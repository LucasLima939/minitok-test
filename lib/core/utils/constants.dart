class AppConstants {
  // API Related
  static const String apiBaseUrl = 'https://api.example.com';

  // Error Messages
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String cacheErrorMessage =
      'Cache error occurred. Please try again.';
  static const String networkErrorMessage =
      'Network error occurred. Please check your connection.';
  static const String unexpectedErrorMessage =
      'Unexpected error occurred. Please try again.';

  // Shared Preferences Keys
  static const String cacheUserKey = 'CACHED_USER';
  static const String cacheTokenKey = 'CACHED_TOKEN';

  // File Types
  static const List<String> supportedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx'
  ];

  // File Size Limits (in bytes)
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
}
