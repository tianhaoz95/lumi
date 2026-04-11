import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/login_screen.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

// Existing validation test for onLogin callback
void main() {
  testWidgets('LoginScreen validates and calls onLogin', (WidgetTester tester) async {
    String? capturedEmail;
    String? capturedPassword;

    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(
        onLogin: (email, password) {
          capturedEmail = email;
          capturedPassword = password;
        },
      ),
    ));

    // Initially, enter invalid email and short password
    await tester.enterText(find.byKey(const Key('email_field')), 'not-an-email');
    await tester.enterText(find.byKey(const Key('password_field')), 'short');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Should not call onLogin because validation fails
    expect(capturedEmail, isNull);
    expect(capturedPassword, isNull);

    // Enter valid values
    await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'VerySecret123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(capturedEmail, 'test@lumi.com');
    expect(capturedPassword, 'VerySecret123');
  });

  // New tests: success and failure flows using AppwriteService injection
  group('Login flow with AppwriteService', () {
    testWidgets('Login success navigates to HomeScreen', (WidgetTester tester) async {
      // Arrange: inject fake success account
      AppwriteService.instance.setAccountForTest(_FakeAccountSuccess());

      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      // Enter valid email/password
      await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'TestPass123!');

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Assert: HomeScreen content is shown
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Login failure shows snackbar', (WidgetTester tester) async {
      AppwriteService.instance.setAccountForTest(_FakeAccountFail());

      await tester.pumpWidget(MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byKey(const Key('email_field')), 'bad@lumi.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'badpass12');

      await tester.tap(find.byKey(const Key('login_button')));
      // Allow async tasks to complete and show snackbar
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });
  });
}

// Fake account implementations
class _FakeAccountSuccess {
  Future<void> createSession({required String email, required String password}) async {
    return Future<void>.value();
  }
}

class _FakeAccountFail {
  Future<void> createSession({required String email, required String password}) async {
    throw Exception('Invalid credentials');
  }
}
