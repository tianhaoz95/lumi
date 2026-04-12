import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumi/features/home/home_impl.dart';
import 'package:lumi/shared/chat/chat_service.dart';
import 'package:lumi/shared/chat/chat_providers.dart';

void main() {
  testWidgets('send button disables while chat stream is active', (WidgetTester tester) async {
    // Create a controller to drive the mock stream
    final controller = StreamController<InferenceChunk>();

    final mockService = ChatService(streamProvider: ({required String prompt, required ModelTier modelTier}) => controller.stream);

    await tester.pumpWidget(ProviderScope(overrides: [chatServiceProvider.overrideWithValue(mockService)], child: MaterialApp(home: HomeScreen())));

    // Enter text
    await tester.enterText(find.byKey(const Key('chat_input')), 'Hello');
    await tester.pumpAndSettle();

    // Tap send
    await tester.tap(find.byKey(const Key('send_button')));
    await tester.pump();

    // After tapping, send button should be disabled (onPressed == null)
    final sendBtn = tester.widget<IconButton>(find.byKey(const Key('send_button')));
    expect(sendBtn.onPressed, isNull);

    // Emit one chunk (not final)
    controller.add(const InferenceChunk(token: 'Hello', isFinal: false, tokensPerSecond: 0.0));
    await tester.pump(const Duration(milliseconds: 100));

    // Still disabled
    final sendBtn2 = tester.widget<IconButton>(find.byKey(const Key('send_button')));
    expect(sendBtn2.onPressed, isNull);

    // Emit final chunk
    controller.add(const InferenceChunk(token: '', isFinal: true, tokensPerSecond: 0.0));
    await tester.pumpAndSettle();

    // Now send button should be enabled
    final sendBtn3 = tester.widget<IconButton>(find.byKey(const Key('send_button')));
    expect(sendBtn3.onPressed, isNotNull);

    await controller.close();
  });
}
