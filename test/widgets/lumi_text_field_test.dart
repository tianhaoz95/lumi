import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/lib/shared/widgets/lumi_text_field.dart';
import 'package:lumi/lib/core/theme.dart';

void main() {
  testWidgets('LumiTextField builds and shows hint + leading icon', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(MaterialApp(
      theme: getLumiTheme(),
      home: Scaffold(
        body: Center(
          child: LumiTextField(
            controller: controller,
            hintText: 'Search receipts',
            leading: const Icon(Icons.search),
          ),
        ),
      ),
    ));

    // Finds the widget
    expect(find.byType(LumiTextField), findsOneWidget);
    // Hint text present
    expect(find.text('Search receipts'), findsOneWidget);
    // Leading icon present
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
