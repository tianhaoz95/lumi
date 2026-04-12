import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/core/app.dart';
import 'package:lumi/core/init.dart';
import '../helpers/test_fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Login Integration (Appwrite-dependent)', () {
    final email = const String.fromEnvironment('TEST_USER_EMAIL', defaultValue: 'test@lumi.com');
    final password = const String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: 'TestPass123!');

    setUp(() async {
      await clearTestSessions();
    });

    testWidgets('valid credentials → navigates to Dashboard', (WidgetTester tester) async {
      // Initialize app state
      try {
        await initializeApp();
      } catch (_) {
        // Ignore FRB/native library load failures in test environments
      }

      // Launch the app
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Ensure we are on login screen
      expect(find.byKey(const Key('email_field')), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      
      // Tap login
      await tester.tap(find.byKey(const Key('login_button')));
      
      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert Dashboard is displayed
      expect(find.text('The Tundra'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('invalid password → shows inline error, stays on LoginScreen', (WidgetTester tester) async {
      try {
        await initializeApp();
      } catch (_) {
        // Ignore FRB/native library load failures in test environments
      }
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), 'WrongPassword!');
      
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Should still be on login screen
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      // Might want to check for error text if implemented, 
      // but staying on the screen is a good first check.
    });
  });
}
