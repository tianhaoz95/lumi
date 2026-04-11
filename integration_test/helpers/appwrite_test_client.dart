// integration_test/helpers/appwrite_test_client.dart

/// Lightweight Appwrite test client builder used by integration tests.
/// Reads values from dart-define at test runtime.

import 'package:appwrite/appwrite.dart';

Client buildTestClient() {
  final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: 'http://localhost/v1');
  final projectId = const String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: 'lumi-test');

  return Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId);
}
