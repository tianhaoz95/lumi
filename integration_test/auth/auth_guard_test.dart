import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// NOTE: This integration test requires a local Appwrite instance and .env.test.
// If Appwrite is not available, these tests are intentionally skipped and
// contain TODOs to implement the full app launch and deep-link assertions.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Guard Integration (Appwrite-dependent)', () {
    setUpAll(() async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) {
        print('APPWRITE_ENDPOINT not provided. Skipping Appwrite setup in setUpAll.');
        return;
      }
      // TODO: call clearTestSessions() from integration_test/helpers/test_fixtures.dart
      // if Appwrite is available to ensure a clean start.
    });

    testWidgets('unauthenticated cold start → redirected to LoginScreen', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Launch the app (e.g., app.main()), wait for initial navigation to settle,
      // assert that LoginScreen is visible (find by key or text). This requires a
      // running Appwrite instance and .env.test with TEST_USER credentials.

    }, skip: true);

    testWidgets('authenticated cold start → HomeScreen rendered', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Use integration_test/helpers/test_fixtures.dart to create a test session
      // (createTestSession) and then launch the app. Assert HomeScreen is rendered.

    }, skip: true);
  });
}
