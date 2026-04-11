import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumi/core/app.dart';
import 'package:lumi/features/auth/auth_notifier.dart';
import 'package:lumi/features/home/home.dart';
import 'package:lumi/features/auth/login_screen.dart';

void main() {
  testWidgets('unauthenticated app redirects to LoginScreen', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('authenticated app renders HomeScreen', (WidgetTester tester) async {
    final container = ProviderContainer();

    // Set authenticated state before building the widget tree.
    container.read(authNotifierProvider.notifier).state = const AuthState.authenticated();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
