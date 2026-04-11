import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumi/shared/widgets/tokens_overlay.dart';
import 'package:lumi/shared/widgets/lumi_card.dart';

void main() {
  testWidgets('TokensOverlay shows TPS when provided and in debug mode', (tester) async {
    // TokensOverlay returns a Positioned; wrap in a Stack
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Stack(children: [TokensOverlay(tokensPerSecond: 42.0)]))));

    await tester.pumpAndSettle();

    expect(find.text('TPS: 42.0'), findsOneWidget);
  });

  testWidgets('TokensOverlay hides when null', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Stack(children: [TokensOverlay(tokensPerSecond: null)]))));
    await tester.pumpAndSettle();
    expect(find.byType(LumiCard), findsNothing);
  });
}
