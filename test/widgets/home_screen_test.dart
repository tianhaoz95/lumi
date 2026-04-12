import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/core/theme.dart';
import 'package:lumi/features/home/home.dart';
import 'package:lumi/shared/widgets/kit_ghost.dart';
import 'package:lumi/shared/chat/chat_service.dart';
import 'package:lumi/shared/chat/chat_providers.dart';

void main() {
  testWidgets('HomeScreen renders top bar, KitGhost or chat and input bar', (WidgetTester tester) async {
    // Mock ChatService to avoid FRB initialization in widget tests
    final mockChatService = ChatService(
      streamProvider: ({required String prompt, required ModelTier modelTier}) async* {
        yield InferenceChunk(token: 'Assistant: ', isFinal: false, tokensPerSecond: 10.0);
        yield InferenceChunk(token: 'I heard you.', isFinal: false, tokensPerSecond: 10.0);
        yield InferenceChunk(token: '', isFinal: true, tokensPerSecond: 0.0);
      },
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        chatServiceProvider.overrideWithValue(mockChatService),
      ],
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
    
    await tester.pumpAndSettle();
    expect(find.textContaining('Hello Lumi'), findsWidgets);
  });
}
