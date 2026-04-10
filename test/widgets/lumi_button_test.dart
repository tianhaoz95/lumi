import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/lumi_button.dart';
import 'package:lumi/core/theme.dart';

void main() {
  testWidgets('LumiButton calls onPressed and renders gradient and pill shape', (WidgetTester tester) async {
    var pressed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: LumiButton(
            onPressed: () => pressed = true,
            child: const Text('Test'),
          ),
        ),
      ),
    ));

    // Find the button by text
    expect(find.text('Test'), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);

    // Verify the container has a BoxDecoration with gradient
    final containerFinder = find.descendant(of: find.byType(LumiButton), matching: find.byType(Container));
    expect(containerFinder, findsWidgets);

    // Inspect one Container's decoration
    final containerWidget = tester.widgetList<Container>(containerFinder).first;
    final decoration = containerWidget.decoration as BoxDecoration?;
    expect(decoration, isNotNull);
    expect(decoration!.borderRadius, isNotNull);
    expect(decoration.borderRadius, isA<BorderRadius>());
    expect(decoration.gradient, isNotNull);

    // Ensure border radius is pill (very large)
    final br = decoration.borderRadius as BorderRadius;
    expect((br.topLeft.x), greaterThanOrEqualTo(LumiRadius.defaultRadius));
  });
}
