import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumi/core/app.dart';
import 'package:lumi/core/init.dart';
import 'package:lumi/features/auth/appwrite_service.dart';
import 'package:lumi/features/dashboard/dashboard.dart';
import 'package:lumi/shared/chat/chat_service.dart';
import 'package:lumi/shared/chat/chat_providers.dart';
import 'package:lumi/shared/bridge/inference.dart' as bridge;
import 'package:lumi/features/home/home_impl.dart';
import 'package:lumi/features/auth/auth_notifier.dart';
import 'package:lumi/shared/bridge/transactions_bridge.dart' as txshim;
import 'package:lumi/shared/models/transaction_summary.dart';

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

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier() {
    state = const AuthState.authenticated();
  }
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
      // Lightweight init for test environments.
      try {
        await initializeApp();
      } catch (_) {
        // ignore
      }

      // Use fake account to avoid network dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Launch app
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Ensure login screen shown
      expect(find.byKey(const Key('email_field')), findsOneWidget);

      // Enter credentials and submit
      await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.test');
      await tester.enterText(find.byKey(const Key('password_field')), 'Password123');
      final loginBtn = find.byKey(const Key('login_button'));
      expect(loginBtn, findsOneWidget);
      await tester.tap(loginBtn);

      // Allow async auth flows to complete
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify that Home is shown by presence of chat input
      expect(find.byKey(const Key('chat_input')), findsOneWidget);

      // Ensure fake account recorded session creation
      expect(fake.sessionCreated, isTrue);
    }, skip: false);

    testWidgets('Dashboard Load', (WidgetTester tester) async {
      // Lightweight init for test environments.
      try {
        await initializeApp();
      } catch (_) {
        // ignore
      }

      // Use fake account to avoid network dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Pump the DashboardScreen directly so this test is self-contained and
      // does not rely on full navigation or external services.
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));

      // Allow async shimbed fetches to complete.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify metric cards present
      expect(find.byKey(const Key('metric_current_expenses')), findsOneWidget);
      expect(find.byKey(const Key('metric_mileage')), findsOneWidget);

      // Verify recent activity list present and contains at least one known item
      final recentList = find.byKey(const Key('recent_activity_list'));
      expect(recentList, findsOneWidget);

      // Check for a known shimbed vendor name from transactions_bridge.dart
      expect(find.text('Coffee House'), findsOneWidget);
    }, skip: false);

    testWidgets('Chat Interaction', (WidgetTester tester) async {
      // Lightweight init for test environments.
      try {
        await initializeApp();
      } catch (_) {
        // ignore
      }

      // Use fake account to avoid network dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Create a fake ChatService that returns a non-echo response stream.
      final fakeChatService = ChatService(
        streamProvider: ({required String prompt, required bridge.ModelTier modelTier}) {
          // Simulate streaming tokens for a friendly non-echo reply.
          final chunks = [
            bridge.InferenceChunk(token: 'Hi, ', isFinal: false, tokensPerSecond: 0.0),
            bridge.InferenceChunk(token: 'I am Lumi.', isFinal: true, tokensPerSecond: 0.0),
          ];
          // Emit with a small delay between chunks so the UI streaming code updates.
          return Stream<bridge.InferenceChunk>.fromIterable(chunks);
        },
      );

      // Launch HomeScreen directly with chatServiceProvider overridden to use fakeChatService.
      await tester.pumpWidget(ProviderScope(overrides: [chatServiceProvider.overrideWithValue(fakeChatService)], child: const MaterialApp(home: HomeScreen())));
      await tester.pumpAndSettle();

      // Ensure chat input is present
      expect(find.byKey(const Key('chat_input')), findsOneWidget);

      // Enter a user message and send
      await tester.enterText(find.byKey(const Key('chat_input')), 'Hello Lumi');
      await tester.tap(find.byKey(const Key('send_button')));

      // Allow stream handling and UI updates
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Verify user message shown
      expect(find.text('Hello Lumi'), findsOneWidget);

      // Verify assistant replied with the non-echo message
      expect(find.text('Hi, I am Lumi.'), findsOneWidget);
    }, skip: false);

    testWidgets('Receipt Logging', (WidgetTester tester) async {
      // Lightweight init for test environments.
      try {
        await initializeApp();
      } catch (_) {
        // ignore
      }

      // Use fake account to avoid network dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Inject a simulated receipt by injecting transactions into the shim.
      txshim.injectRecentTransactions([
        TransactionSummary(id: '99', vendor: 'Scanned Bakery', category: 'food', amount: -12.30, date: '2026-04-12', isCredit: false),
        // keep a couple of known items as well to emulate a realistic list
        TransactionSummary(id: '100', vendor: 'Coffee House', category: 'food', amount: -6.75, date: '2026-04-10', isCredit: false),
      ]);

      // Pump the DashboardScreen directly so this test is self-contained.
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));

      // Allow async shimbed fetches to complete.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify the injected receipt/vendor appears in the dashboard recent activity list
      expect(find.text('Scanned Bakery'), findsOneWidget);
    }, skip: false);

    testWidgets('Logout', (WidgetTester tester) async {
      // Lightweight init for test environments.
      try {
        await initializeApp();
      } catch (_) {
        // ignore
      }

      // Use fake account to avoid network dependency.
      final fake = _FakeAccount();
      AppwriteService.instance.setAccountForTest(fake);

      // Launch app
      await tester.pumpWidget(ProviderScope(overrides: [authNotifierProvider.overrideWith((ref) => _TestAuthNotifier())], child: MyApp()));
      await tester.pumpAndSettle();

      // Ensure Home is shown by presence of chat input
      expect(find.byKey(const Key('chat_input')), findsOneWidget);

      // Open Settings via the settings icon in the top app bar
      final settingsBtn = find.widgetWithIcon(IconButton, Icons.settings);
      expect(settingsBtn, findsOneWidget);
      await tester.tap(settingsBtn);
      await tester.pumpAndSettle();

      // Find and tap the Logout button
      final logoutFinder = find.widgetWithIcon(OutlinedButton, Icons.logout);
      expect(logoutFinder, findsOneWidget);
      await tester.tap(logoutFinder);

      // Allow logout flows to complete and for navigation to update
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify that the app navigated back to the Login screen (email field present)
      expect(find.byKey(const Key('email_field')), findsOneWidget);
    }, skip: false);
  });
}
