import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/settings/settings.dart';
import 'package:lumi/features/auth/appwrite_service.dart';
import 'package:lumi/features/auth/auth_notifier.dart';

class _FakeAccount {
  bool deleted = false;
  Future<void> deleteSession({required String sessionId}) async {
    deleted = true;
  }
}

void main() {
  testWidgets('SettingsScreen shows profile, notifications badge and logout triggers Appwrite logout', (WidgetTester tester) async {
    // Inject fake account
    final fake = _FakeAccount();
    AppwriteService.instance.setAccountForTest(fake);

    // Ensure the test viewport is tall enough so the logout button is visible
    tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    addTearDown(() {
      // Reset test window values after the test
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: SettingsScreen(),
      ),
    ));

    await tester.pumpAndSettle();

    // Title
    expect(find.text('The Cabin'), findsOneWidget);

    // Notifications badge
    expect(find.text('3 New'), findsOneWidget);

    // Tap Logout
    final logoutFinder = find.widgetWithIcon(OutlinedButton, Icons.logout);
    expect(logoutFinder, findsOneWidget);
    // Use tapAt center to avoid hit-test issues when layout is slightly different
    await tester.tapAt(tester.getCenter(logoutFinder));
    await tester.pump(); // Start logout
    await tester.pump(const Duration(milliseconds: 100)); // Finish logout
    await tester.pumpAndSettle();

    // fake account should have deleted session
    expect(fake.deleted, isTrue);
    
    // Auth state should be initial
    final BuildContext context = tester.element(find.byType(SettingsScreen));
    final container = ProviderScope.containerOf(context);
    expect(container.read(authNotifierProvider).status, AuthStatus.initial);
  });
}
