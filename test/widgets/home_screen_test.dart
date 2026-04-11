import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/theme.dart';
import 'package:lumi/features/home/home.dart';

void main() {
  testWidgets('HomeScreen renders top bar, KitGhost or chat and input bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: getLumiTheme(),
      home: const HomeScreen(),
    ));

    // Top app bar title
    expect(find.text('Lumi AI'), findsOneWidget);

    // Input widget (TextFormField inside LumiTextField)
    expect(find.byType(TextFormField), findsOneWidget);

    // Kit ghost (since chat has messages, ghost is not present) — ensure at least one chat bubble exists
    expect(find.textContaining('Hello!') , findsOneWidget);

    // Add and mic icons present
    expect(find.byIcon(Icons.add), findsWidgets);
    expect(find.byIcon(Icons.mic), findsWidgets);
  });
}
