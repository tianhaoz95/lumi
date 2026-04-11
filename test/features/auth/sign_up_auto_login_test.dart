import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/auth/sign_up_screen.dart';
import 'package:lumi/features/home/home.dart';

void main() {
  testWidgets('On successful sign up auto-navigates to HomeScreen', (WidgetTester tester) async {
    var called = false;

    Future<void> fakeOnSignUp(String name, String email, String password) async {
      called = true;
      // simulate network latency
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    await tester.pumpWidget(MaterialApp(home: SignUpScreen(onSignUp: fakeOnSignUp)));

    // Fill valid fields
    await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'Password123');
    await tester.tap(find.byKey(const Key('terms_checkbox')));
    await tester.pumpAndSettle();

    // Tap sign up
    await tester.tap(find.byKey(const Key('signup_button')));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    // HomeScreen builds a Center with Text('Home') per implementation.
    expect(find.text('Home'), findsOneWidget);
  });
}
