import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/chat/widgets/insight_card.dart';

void main() {
  testWidgets('InsightCard renders summary correctly', (WidgetTester tester) async {
    final map = {
      'insight_type': 'summary',
      'summary': {'total_expenses': 123.45, 'total_miles': 10.0, 'estimated_deduction': 6.7}
    };

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: InsightCard.fromMap(map))));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('\$123.45'), findsOneWidget);
    expect(find.text('10.0 mi'), findsOneWidget);
  });
}
