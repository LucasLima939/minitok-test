import 'dart:io';

/// An adapter for HTTP client operations
abstract class HttpClientAdapter {
  /// Downloads a file from the given URL and saves it to the specified file path
  Future<void> downloadFile(String url, File destinationFile);
}

/// Default implementation of [HttpClientAdapter] using Dart's HttpClient
class DefaultHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<void> downloadFile(String url, File destinationFile) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    await response.pipe(destinationFile.openWrite());
  }
}
