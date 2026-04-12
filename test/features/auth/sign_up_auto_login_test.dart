import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/auth/sign_up_screen.dart';
import 'package:lumi/features/auth/auth_notifier.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

class FakeAccountSuccess {
  Future<void> createEmailPasswordSession({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  Future<void> create({required String userId, required String email, required String password, String? name}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  testWidgets('On successful sign up auto-login succeeds', (WidgetTester tester) async {
    final svc = AppwriteService.instance;
    svc.setAccountForTest(FakeAccountSuccess());

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: SignUpScreen(),
      ),
    ));

    // Fill valid fields
    await tester.enterText(find.byKey(const Key('name_field')), 'Test User');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@lumi.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'Password123');
    await tester.tap(find.byKey(const Key('terms_checkbox')));
    await tester.pumpAndSettle();

    // Tap sign up
    await tester.tap(find.byKey(const Key('signup_button')));
    // Wait for the async operation
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 100)); // Finish loading
    await tester.pumpAndSettle();

    // Verify that the state is now authenticated (via the provider)
    final BuildContext context = tester.element(find.byType(SignUpScreen));
    final container = ProviderScope.containerOf(context);
    expect(container.read(authNotifierProvider).status, AuthStatus.authenticated);
  });
}
