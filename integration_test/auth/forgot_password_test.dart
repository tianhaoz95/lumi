import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_fixtures.dart' show waitForEmail;

// NOTE: This integration test requires a local Appwrite + Mailhog stack and
// .env.test. If those services are not available, the tests are intentionally
// skipped. TODO: implement full app launch and widget interactions when
// running on a CI or developer machine with Appwrite.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Forgot Password Integration (Appwrite + Mailhog dependent)', () {
    setUpAll(() async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) {
        print('APPWRITE_ENDPOINT not provided. Skipping Appwrite-dependent setup in setUpAll.');
        return;
      }
      // TODO: call clearTestSessions() from helpers when Appwrite is available.
    });

    testWidgets('submit reset@lumi.com → success state shown', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Launch the app, navigate to ForgotPasswordScreen, enter TEST_RESET_EMAIL
      // (from .env.test), tap submit, and assert success state "Check your inbox" is shown.

    }, skip: true);

    testWidgets('password reset email delivered to Mailhog', (WidgetTester tester) async {
      // This test contacts Mailhog only; it does not require Appwrite if the
      // password-reset flow is triggered by an external process. We guard it
      // by checking MAILHOG_URL via the default in waitForEmail. If Mailhog is
      // not available, the helper will timeout and the test should be run in
      // integration mode with the services up.

      // For now the test is marked skipped in CI/dev until infra is available.
      final mailhogEnv = const String.fromEnvironment('MAILHOG_URL', defaultValue: '');
      if (mailhogEnv.isEmpty) return;

      // Example usage (uncomment when running with Mailhog + Appwrite up):
      // final body = await waitForEmail('reset@lumi.com', timeout: Duration(seconds: 15));
      // expect(body, isNotEmpty);
    }, skip: true);
  });
}
