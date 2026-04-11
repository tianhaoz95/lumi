import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/home/home_impl.dart';

void main() {
  testWidgets('Add button shows bottom sheet with Camera and Photo Library', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));

    // Ensure the add button exists
    final addButton = find.byTooltip('Add');
    expect(addButton, findsOneWidget);

    // Tap the add button
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Expect bottom sheet options
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Photo Library'), findsOneWidget);
  });
}
