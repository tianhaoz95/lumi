import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/dashboard/dashboard.dart';

void main() {
  testWidgets('Dashboard displays summary metrics and recent activity', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));
    // Allow async fetch shim to complete
    await tester.pump(); 
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('metric_current_expenses')), findsOneWidget);
    expect(find.textContaining('\$1234.56'), findsOneWidget);
    expect(find.byKey(const Key('recent_activity_list')), findsOneWidget);
  });
}
