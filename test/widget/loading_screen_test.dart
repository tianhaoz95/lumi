import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/loading/loading_screen.dart';

void main() {
  testWidgets('LoadingScreen shows progress and updates', (WidgetTester tester) async {
    final controller = StreamController<double>();
    await tester.pumpWidget(MaterialApp(home: LoadingScreen(progressStream: controller.stream, transitionDelay: Duration.zero, onComplete: () {})));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    controller.add(0.3);
    await tester.pumpAndSettle();
    expect(find.text('30%'), findsOneWidget);

    controller.add(0.75);
    await tester.pumpAndSettle();
    expect(find.text('75%'), findsOneWidget);

    await controller.close();
  });

  testWidgets('LoadingScreen navigates to /login on complete', (WidgetTester tester) async {
    final controller = StreamController<double>();

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => LoadingScreen(
              progressStream: controller.stream,
              transitionDelay: Duration.zero,
              onComplete: () => navigatorKey.currentState?.pushReplacementNamed('/login'),
            ),
        '/login': (context) => const Scaffold(body: Center(child: Text('Login'))),
      },
      initialRoute: '/',
    ));

    controller.add(1.0);
    await tester.pump(); // process stream event
    await tester.pump(const Duration(milliseconds: 600)); // allow transition delay to elapse
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);

    await controller.close();
  });
}
