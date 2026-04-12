import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/auth/login_screen.dart';
import 'package:lumi/features/auth/appwrite_service.dart';
import 'package:lumi/features/auth/auth_notifier.dart';

void main() {
  testWidgets('LoginScreen validates fields', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: LoginScreen(),
      ),
    ));

    // Initially, enter invalid email and short password
    await tester.enterText(find.byKey(const Key('email_field')), 'not-an-email');
    await tester.enterText(find.byKey(const Key('password_field')), 'short');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  group('Login flow with AppwriteService', () {
    testWidgets('Login success sets authenticated state', (WidgetTester tester) async {
      final svc = AppwriteService.instance;
      svc.setAccountForTest(_FakeAccountSuccess());

      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));

      // Enter valid email/password
      await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'TestPass123!');

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 100)); // Finish loading
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(LoginScreen));
      final container = ProviderScope.containerOf(context);
      expect(container.read(authNotifierProvider).status, AuthStatus.authenticated);
    });

    testWidgets('Login failure shows snackbar', (WidgetTester tester) async {
      final svc = AppwriteService.instance;
      svc.setAccountForTest(_FakeAccountFail());

      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ));

      await tester.enterText(find.byKey(const Key('email_field')), 'bad@lumi.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'badpass12');

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 100)); // Finish loading
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });
  });
}

// Fake account implementations
class _FakeAccountSuccess {
  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _FakeAccountFail {
  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    throw Exception('Invalid credentials');
  }
}
