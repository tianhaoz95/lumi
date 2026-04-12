import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lumi/shared/widgets/atmospheric_background.dart';

void main() {
  testWidgets('AtmosphericBackground populates grain cache when shown', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AtmosphericBackground())));
    await tester.pumpAndSettle();
    expect(getAtmosphericGrainCacheSize(), greaterThan(0));
  });
}
