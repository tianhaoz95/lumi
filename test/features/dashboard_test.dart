import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/core/theme.dart';
import 'package:lumi/features/dashboard/dashboard.dart';

void main() {
  testWidgets('bento grid renders 3 columns on wide viewport', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: Center(
          child: SizedBox(
            width: 1200,
            child: MediaQuery(
              data: MediaQueryData(size: Size(1200, 800)),
              child: DashboardScreen(),
            ),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byKey(const Key('bento_grid')));
    final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);

    // Metric cards exist
    expect(find.byKey(const Key('metric_current_expenses')), findsOneWidget);
    expect(find.byKey(const Key('metric_working_hours')), findsOneWidget);
    expect(find.byKey(const Key('metric_mileage')), findsOneWidget);
  });

  testWidgets('bento grid renders 1 column on narrow viewport', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: Center(
          child: SizedBox(
            width: 320,
            child: MediaQuery(
              data: MediaQueryData(size: Size(320, 800)),
              child: DashboardScreen(),
            ),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byKey(const Key('bento_grid')));
    final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 1);
  });
}
