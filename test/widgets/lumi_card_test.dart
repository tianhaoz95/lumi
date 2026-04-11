import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/lumi_card.dart';

void main() {
  testWidgets('LumiCard renders child and BackdropFilter', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LumiCard(
            child: const Text('Hello Lumi'),
          ),
        ),
      ),
    );

    // Child present
    expect(find.text('Hello Lumi'), findsOneWidget);

    // BackdropFilter applied for glassmorphism
    expect(find.byType(BackdropFilter), findsOneWidget);

    // InkWell responds to taps (sanity)
    await tester.tap(find.byType(LumiCard));
    await tester.pumpAndSettle();
  });
}
