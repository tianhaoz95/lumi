import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// NOTE: This integration test requires a local Appwrite instance and .env.test.
// If Appwrite is not available, these tests are skipped by default and contain
// TODOs for a developer to implement the app launch and widget interactions.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Login Integration (Appwrite-dependent)', () {
    setUpAll(() async {
      // Attempt to clear test sessions if Appwrite is configured. Helpers exist
      // in integration_test/helpers/ but may require Appwrite to be up.
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) {
        print('APPWRITE_ENDPOINT not provided. Skipping Appwrite setup in setUpAll.');
        return;
      }
      // TODO: call clearTestSessions() from helpers when Appwrite is available.
    });

    testWidgets('valid credentials → navigates to HomeScreen', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Launch the app, enter credentials from .env.test (TEST_USER_EMAIL / TEST_USER_PASSWORD),
      // tap the primary CTA, and assert HomeScreen is displayed.

    }, skip: true);

    testWidgets('invalid password → shows inline error, stays on LoginScreen', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return;

      // TODO: Launch the app, enter valid email and invalid password, tap CTA,
      // expect inline error message and still on LoginScreen.

    }, skip: true);

    testWidgets('empty email → validation error displayed', (WidgetTester tester) async {
      // Pure widget validation test — can be implemented as a unit/widget test
      // in test/ without Appwrite. Kept here for integration completeness.
      // TODO: Move to test/ for unit coverage.
    }, skip: true);
  });
}
