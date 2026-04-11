import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/settings/settings.dart';
import 'package:lumi/features/auth/appwrite_service.dart';

class _FakeAccount {
  bool deleted = false;
  Future<void> deleteSession(String id) async {
    deleted = true;
  }
}

void main() {
  testWidgets('SettingsScreen shows profile, notifications badge and logout triggers Appwrite logout', (WidgetTester tester) async {
    // Inject fake account
    final fake = _FakeAccount();
    AppwriteService.instance.setAccountForTest(fake);

    await tester.pumpWidget(MaterialApp(
      routes: {
        '/login': (_) => const Scaffold(body: Center(child: Text('Login'))),
      },
      home: const SettingsScreen(),
    ));

    await tester.pumpAndSettle();

    // Title
    expect(find.text('The Cabin'), findsOneWidget);

    // Notifications badge
    expect(find.text('3 New'), findsOneWidget);

    // Tap Logout
    final logoutFinder = find.widgetWithIcon(OutlinedButton, Icons.logout);
    expect(logoutFinder, findsOneWidget);
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    // fake account should have deleted session
    expect(fake.deleted, isTrue);

    // Navigator should have pushed to /login (replaced)
    expect(find.text('Login'), findsOneWidget);
  });
}
