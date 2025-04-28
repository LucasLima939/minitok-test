import 'dart:io';

/// An adapter for temporary directory operations
abstract class TempDirectoryAdapter {
  /// Returns the system's temporary directory path
  String getTempDirectoryPath();

  /// Creates a file with the given name in the system's temporary directory
  File createTempFile(String fileName);
}

/// Default implementation of [TempDirectoryAdapter] using Dart's Directory.systemTemp
class DefaultTempDirectoryAdapter implements TempDirectoryAdapter {
  @override
  String getTempDirectoryPath() {
    return Directory.systemTemp.path;
  }

  @override
  File createTempFile(String fileName) {
    return File('${Directory.systemTemp.path}/$fileName');
  }
}
