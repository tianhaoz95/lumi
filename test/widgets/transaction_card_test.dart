import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/transactions/widgets/transaction_card.dart';

void main() {
  testWidgets('TransactionCard shows AI badge when tagged and Confirm invokes callback', (WidgetTester tester) async {
    var confirmed = false;

    final widget = MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: Colors.green, onSurface: Colors.black),
      ),
      home: Scaffold(
        body: TransactionCard(
          vendor: 'Starbucks',
          category: 'coffee',
          date: '2026-04-01',
          amount: -5.5,
          isTagged: true,
          onConfirm: () => confirmed = true,
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    // AI badge present
    expect(find.text('AI'), findsOneWidget);

    // Amount text present
    expect(find.text('-\$5.50'), findsOneWidget);

    // Confirm button exists and triggers callback
    final confirmButton = find.byTooltip('Confirm');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);

    // Verify amount color uses onSurface for negative value
    final amountText = tester.widget<Text>(find.text('-\$5.50'));
    expect(amountText.style?.color, equals(Colors.black));
  });
}
