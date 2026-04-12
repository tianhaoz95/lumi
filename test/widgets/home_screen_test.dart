import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/core/theme.dart';
import 'package:lumi/features/home/home.dart';
import 'package:lumi/shared/widgets/kit_ghost.dart';

void main() {
  testWidgets('HomeScreen renders top bar, KitGhost or chat and input bar', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: getLumiTheme(),
        home: const HomeScreen(),
      ),
    ));

    // Top app bar title
    expect(find.text('Lumi AI'), findsOneWidget);

    // Input widget (LumiTextField)
    expect(find.byKey(const Key('chat_input')), findsOneWidget);

    // Kit ghost should be present when no messages
    expect(find.byType(KitGhost), findsOneWidget);

    // Add and mic icons present
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    
    // Enter text and send
    await tester.enterText(find.byKey(const Key('chat_input')), 'Hello Lumi');
    await tester.tap(find.byKey(const Key('send_button')));
    await tester.pump();
    
    // Now KitGhost should be gone and message should be present
    expect(find.byType(KitGhost), findsNothing);
    expect(find.text('Hello Lumi'), findsOneWidget);
  });
}
