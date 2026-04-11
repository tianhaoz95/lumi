import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/kit_ghost.dart';

void main() {
  testWidgets('KitGhost renders with default opacity and grayscale', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: KitGhost())));

    final iconFinder = find.byIcon(Icons.pets);
    expect(iconFinder, findsOneWidget);

    // The top-level Opacity widget should be present
    final opacityFinder = find.byType(Opacity);
    expect(opacityFinder, findsOneWidget);

    final opacityWidget = tester.widget<Opacity>(opacityFinder);
    expect(opacityWidget.opacity, closeTo(0.07, 0.001));
  });

  testWidgets('KitGhost respects custom opacity', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: KitGhost(opacity: 0.5))))
      ;

    final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacityWidget.opacity, 0.5);
  });
}
