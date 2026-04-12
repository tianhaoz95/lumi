import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/auth/sign_up_screen.dart';
import 'package:lumi/shared/widgets/lumi_buttons.dart';

void main() {
  testWidgets('Sign up CTA disabled until terms checked and basic fields filled', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SignUpScreen())));

    final signupFinder = find.byKey(const Key('signup_button'));
    expect(signupFinder, findsOneWidget);

    final LumiPrimaryButton btn = tester.widget<LumiPrimaryButton>(signupFinder);
    expect(btn.onPressed, isNull);

    // Fill fields but don't check terms
    await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'Password123');
    await tester.pumpAndSettle();

    final LumiPrimaryButton btn2 = tester.widget<LumiPrimaryButton>(signupFinder);
    expect(btn2.onPressed, isNull, reason: 'CTA remains disabled until terms checked');

    // Check terms
    await tester.tap(find.byKey(const Key('terms_checkbox')));
    await tester.pumpAndSettle();

    final LumiPrimaryButton btn3 = tester.widget<LumiPrimaryButton>(signupFinder);
    expect(btn3.onPressed, isNotNull, reason: 'CTA enabled after terms checked and fields filled');
  });

  testWidgets('Sign up shows password validation error for short password', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SignUpScreen())));

    // Fill fields with short password
    await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'short');
    await tester.tap(find.byKey(const Key('terms_checkbox')));
    await tester.pumpAndSettle();

    final signupFinder = find.byKey(const Key('signup_button'));
    expect(signupFinder, findsOneWidget);

    // Button should be enabled now
    final LumiPrimaryButton btn = tester.widget<LumiPrimaryButton>(signupFinder);
    expect(btn.onPressed, isNotNull);

    // Tap button to trigger validation
    await tester.tap(signupFinder);
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });
}
