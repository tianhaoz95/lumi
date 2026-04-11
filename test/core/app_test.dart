import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumi/core/app.dart';

void main() {
  testWidgets('MyApp shows router after models ready with fade', (WidgetTester tester) async {
    // Use default provider (which resolves true in tests).
    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );

    // Initial frame: the FadeTransition animation takes 500ms, pump to let it complete.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Expect no loading indicator present.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Expect MaterialApp exists in the widget tree.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
