import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumi/core/app.dart';
import 'package:lumi/core/init.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

// Golden Path integration test scaffold for Project Lumi.
// These tests are scaffolded and skipped by default because they require
// a running Appwrite instance and a real device/emulator with Flutter.

class _FakeAccount {
  bool created = false;
  bool sessionCreated = false;

  Future<void> create({required String userId, required String email, required String password, required String name}) async {
    created = true;
  }

  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    sessionCreated = true;
  }

  Future<void> deleteSession({required String sessionId}) async {}

  Future<dynamic> get() async => {'id': 'fake'};
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Golden Path', () {
    testWidgets('Onboarding/SignUp', (WidgetTester tester) async {
      // Integration test: programmatically create a new account using a fake
      // Appwrite Account implementation and assert the app navigates to Home.

      // Perform lightweight app initialization for integration tests. Wrap in
      // try/catch to avoid failing when native bridges are unavailable in CI.
      try {
        await initializeApp();
      } catch (_) {
        // Ignore init failures in test environments without FRB or models.
      }

      // Inject fake account to avoid real network/Appwrite dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Launch the full app inside a ProviderScope so Riverpod providers work.
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // On the Login screen, tap the "Create one" CTA to open Sign Up.
      final signupNav = find.text("Don't have an account? Create one");
      expect(signupNav, findsOneWidget);
      await tester.tap(signupNav);
      await tester.pumpAndSettle();

      // Fill in sign up form fields and accept terms.
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
      await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.test');
      await tester.enterText(find.byKey(const Key('password_field')), 'Password123');
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Submit sign up and wait for navigation to Home (chat input present).
      final signupBtn = find.byKey(const Key('signup_button'));
      expect(signupBtn, findsOneWidget);
      await tester.tap(signupBtn);

      // Allow async auth flows to complete.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify that Home screen is shown by checking for the chat input widget.
      expect(find.byKey(const Key('chat_input')), findsOneWidget);

      // Sanity: ensure fake account recorded operations.
      expect(fake.created, isTrue);
      expect(fake.sessionCreated, isTrue);
    }, skip: false);

    testWidgets('Login', (WidgetTester tester) async {
      // Steps:
      // 1. Launch the app.
      // 2. Enter known credentials and sign in.
      // 3. Assert navigation to dashboard and presence of user name.
    }, skip: true);

    testWidgets('Dashboard Load', (WidgetTester tester) async {
      // Steps:
      // 1. Ensure summary cards and recent activity widgets are present.
      // 2. Assert that recent activity list is non-empty (or shows empty state appropriately).
    }, skip: true);

    testWidgets('Chat Interaction', (WidgetTester tester) async {
      // Steps:
      // 1. Open chat screen, send a message to Lumi.
      // 2. Wait for a non-echo response (mock or real model).
      // 3. Assert that the response is displayed and not identical to the sent message.
    }, skip: true);

    testWidgets('Receipt Logging', (WidgetTester tester) async {
      // Steps:
      // 1. Use diagnostics or a mocked extractor to simulate receipt parsing.
      // 2. Verify the new transaction/receipt appears in the dashboard.
    }, skip: true);

    testWidgets('Logout', (WidgetTester tester) async {
      // Steps:
      // 1. Trigger logout from settings.
      // 2. Verify session cleared and app shows login screen.
    }, skip: true);
  });
}
