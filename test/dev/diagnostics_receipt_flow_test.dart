import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/dev/diagnostics_screen.dart';
import 'package:lumi/features/transactions/widgets/transaction_card.dart';

void main() {
  testWidgets('DiagnosticsScreen shows TransactionCard after processing sample receipt', (WidgetTester tester) async {
    final widget = MaterialApp(
      home: Scaffold(body: DiagnosticsScreen()),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    final processButton = find.text('Process Sample Receipt (dev)');
    expect(processButton, findsOneWidget);

    await tester.tap(processButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    // TransactionCard should appear with vendor and formatted negative amount
    expect(find.byType(TransactionCard), findsOneWidget);
    expect(find.text('Corner Store'), findsOneWidget);
    expect(find.text('-\$12.34'), findsOneWidget);
  });
}
