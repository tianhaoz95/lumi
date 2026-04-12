import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/widgets/kit_animated.dart';

void main() {
  testWidgets('KitAnimated enters thinking state when requested', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: KitAnimated(state: KitState.thinking, size: 80.0),
          ),
        ),
      ),
    );

    // initial pump
    await tester.pump();

    // Verify that the fox base widget exists
    expect(find.byKey(const Key('kit-fox-base')), findsWidgets);

    // Let the thinking animation progress a bit
    await tester.pump(const Duration(milliseconds: 200));

    // Since thinking uses a translation, ensure widget tree still contains base
    expect(find.byKey(const Key('kit-fox-base')), findsWidgets);
  });

  testWidgets('KitAnimated plays found one-shot animation and calls completion', (WidgetTester tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: KitAnimated(state: KitState.found, onFoundComplete: () { called = true; }, size: 80.0),
          ),
        ),
      ),
    );

    // initial pump
    await tester.pump();

    // progress animation to completion
    await tester.pump(const Duration(milliseconds: 900));

    expect(called, isTrue);
  });
}
