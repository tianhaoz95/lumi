import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumi/features/home/home_impl.dart';
import 'package:lumi/shared/chat/chat_service.dart';
import 'package:lumi/shared/chat/chat_providers.dart';
import 'package:lumi/features/chat/widgets/insight_card.dart';

void main() {
  testWidgets('HomeScreen renders InsightCard when agent emits tool-result JSON', (WidgetTester tester) async {
    // Build a ChatService that emits a single JSON chunk as the assistant response
    Stream<InferenceChunk> mockAgentChat({required String prompt, required ModelTier modelTier}) async* {
      final payload = jsonEncode({
        'insight_type': 'summary',
        'summary': {'total_expenses': 88.5, 'total_miles': 5.0, 'estimated_deduction': 3.35}
      });
      yield InferenceChunk(token: payload, isFinal: true, tokensPerSecond: 0.0);
    }

    final overrideService = ChatService(streamProvider: ({required String prompt, required ModelTier modelTier}) => mockAgentChat(prompt: prompt, modelTier: modelTier));

    await tester.pumpWidget(ProviderScope(overrides: [chatServiceProvider.overrideWithValue(overrideService)], child: MaterialApp(home: HomeScreen())));

    // Enter text and tap send
    await tester.enterText(find.byKey(const Key('chat_input')), 'Show me my summary');
    await tester.tap(find.byKey(const Key('send_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Expect InsightCard present
    expect(find.byType(InsightCard), findsOneWidget);
    expect(find.text('\$88.50'), findsOneWidget);
  });
}
