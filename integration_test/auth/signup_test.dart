import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// NOTE: These integration tests require a local Appwrite instance and .env.test.
// If Appwrite is not available, tests are skipped by default and contain
// TODOs for a developer to implement the app launch and widget interactions.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth SignUp Integration (Appwrite-dependent)', () {
    setUpAll(() async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) {
        print('APPWRITE_ENDPOINT not provided. Skipping Appwrite setup in setUpAll.');
        return;
      }
      // TODO: call clearTestSessions() from integration_test/helpers when Appwrite is available.
    });

    testWidgets('create account → auto-logged in → HomeScreen shown', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Launch the app, fill signup form with a unique email, submit,
      // assert HomeScreen is displayed and user is auto-logged in.

    }, skip: true);

    testWidgets('duplicate email → shows error', (WidgetTester tester) async {
      final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
      if (endpoint.isEmpty) return; // Skip when not configured

      // TODO: Attempt to create an account with an existing email and assert
      // the appropriate inline error or snackbar is shown.

    }, skip: true);

    testWidgets('unchecked terms → CTA disabled (UI validation)', (WidgetTester tester) async {
      // This UI validation can be verified as a pure widget test; prefer moving
      // to test/ as a unit/widget test for faster feedback.
      // TODO: See test/auth/signup_widget_test.dart for a unit-level check.
    }, skip: true);
  });
}
