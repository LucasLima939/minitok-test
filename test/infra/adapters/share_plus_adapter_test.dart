import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:minitok_test/infra/adapters/share_plus_adapter.dart';

// Generate mock for SharePlus
@GenerateMocks([SharePlus])
import 'share_plus_adapter_test.mocks.dart';

class MockFile extends Mock implements File {
  @override
  String get path => 'test/path/file.txt';
}

class MockShareResult extends Mock implements ShareResult {}

void main() {
  late SharePlusAdapterImpl sharePlusAdapter;
  late MockSharePlus mockSharePlus;
  late MockShareResult mockShareResult;

  setUp(() {
    mockSharePlus = MockSharePlus();
    mockShareResult = MockShareResult();
    sharePlusAdapter = SharePlusAdapterImpl(mockSharePlus);

    // Setup default behavior
    when(mockSharePlus.share(any)).thenAnswer((_) async => mockShareResult);
  });

  group('SharePlusAdapter', () {
    test('shareFile should call SharePlus.share with correct parameters',
        () async {
      // Arrange
      final mockFile = MockFile();
      final text = 'Test Text';

      // Act
      await sharePlusAdapter.shareFile(mockFile, text: text);
      // Assert
      verify(mockSharePlus.share(any)).called(1);
    });

    test('Should complete when SharePlus.share completes', () async {
      // Arrange
      final mockFile = MockFile();
      final text = 'Test Text';

      // Act
      final result = sharePlusAdapter.shareFile(mockFile, text: text);

      // Assert
      expect(result, completes);
    });

    test('shareFile should throw exception when SharePlus.share fails',
        () async {
      // Arrange
      final mockFile = MockFile();
      final exception = Exception('Failed to share');
      when(mockSharePlus.share(any)).thenThrow(exception);

      // Act & Assert
      expect(
        () => sharePlusAdapter.shareFile(mockFile),
        throwsA(isA<Exception>()),
      );
    });
  });
}
