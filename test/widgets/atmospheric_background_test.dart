import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/atmospheric_background.dart';

void main() {
  testWidgets('AtmosphericBackground builds and contains grain overlay', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtmosphericBackground(),
        ),
      ),
    );

    // Verify the widget tree contains the test key for atmospheric orbs
    expect(find.byKey(const Key('atmospheric-orbs')), findsOneWidget);
    // Also ensure a CustomPaint grain painter exists
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
