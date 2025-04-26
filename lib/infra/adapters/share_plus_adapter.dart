import 'dart:io';
import 'package:share_plus/share_plus.dart';

/// SharePlus adapter interface
abstract class SharePlusAdapter {
  /// Share a single file
  Future<void> shareFile(File file, {String? text});
}

/// Implementation of SharePlus adapter
class SharePlusAdapterImpl implements SharePlusAdapter {
  final SharePlus _sharePlus;
  SharePlusAdapterImpl(this._sharePlus);

  @override
  Future<void> shareFile(File file, {String? text}) async {
    try {
      final params = ShareParams(
        text: text ?? '',
        files: [XFile(file.path)],
      );
      await _sharePlus.share(params);
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }
}
