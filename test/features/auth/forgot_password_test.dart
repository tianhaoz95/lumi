import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen shows success state after send', (WidgetTester tester) async {
    var called = false;
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(
        onSendReset: (email) async {
          expect(email, 'test@lumi.com');
          called = true;
          // simulate network delay
          await Future.delayed(const Duration(milliseconds: 10));
        },
      ),
    ));

    // Enter email
    final emailField = find.byKey(const Key('forgot_email_field'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'test@lumi.com');
    await tester.pumpAndSettle();

    // Tap send
    final sendButton = find.byKey(const Key('send_reset_button'));
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);

    // Wait for async work to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(called, isTrue);

    // Verify success text shown
    expect(find.text('Check your inbox'), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen validates email', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ForgotPasswordScreen(onSendReset: (_) async {})));
    final sendButton = find.byKey(const Key('send_reset_button'));
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.text('Email required'), findsOneWidget);

    final emailField = find.byKey(const Key('forgot_email_field'));
    await tester.enterText(emailField, 'not-an-email');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
  });
}
