import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/widgets/floating_nav_bar.dart';

void main() {
  testWidgets('FloatingNavBar is centered and constrained width', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: FloatingNavBar(
              maxWidth: 600,
              children: const [Icon(Icons.home), SizedBox(width: 16), Icon(Icons.search)],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should find BackdropFilter
    expect(find.byType(BackdropFilter), findsOneWidget);

    // The top-level Container should be present
    expect(find.byType(Container), findsWidgets);

    // Verify that the ConstrainedBox inside FloatingNavBar obeys maxWidth
    final cbFinder = find.descendant(
      of: find.byType(FloatingNavBar),
      matching: find.byType(ConstrainedBox),
    );
    expect(cbFinder, findsOneWidget);
    final constrained = tester.widget<ConstrainedBox>(cbFinder);
    expect(constrained.constraints.maxWidth, equals(600));
  });
}
