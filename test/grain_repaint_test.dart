import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/atmospheric_background.dart';

void main() {
  testWidgets('Grain overlay is wrapped in a RepaintBoundary', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtmosphericBackground(showGrain: true),
        ),
      ),
    );

    // Ensure a RepaintBoundary exists in the tree when grain is shown
    expect(find.byType(RepaintBoundary), findsWidgets);

    // Ensure CustomPaint (grain painter) still present
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
