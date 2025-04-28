// This file exists solely to generate mock classes for repositories
// It doesn't contain any implementation as mocks are generated via build_runner

import 'package:mockito/annotations.dart';
import 'package:minitok_test/domain/repositories/file_repository.dart';

// Generate mock classes
@GenerateMocks([FileRepository])
void main() {
  // This main function is empty and only exists to make this a valid Dart file
  // The @GenerateMocks annotation above is what generates the mock classes
}
