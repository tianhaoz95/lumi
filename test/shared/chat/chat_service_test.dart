import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/chat/chat_service.dart';

void main() {
  test('ChatService.chat forwards chunks from the underlying stream provider', () async {
    // Prepare a mock stream provider that emits two chunks then closes.
    Stream<InferenceChunk> mockStream({required String prompt, required ModelTier modelTier}) async* {
      yield const InferenceChunk(token: 'Hello', isFinal: false, tokensPerSecond: 50.0);
      await Future.delayed(Duration(milliseconds: 10));
      yield const InferenceChunk(token: 'World', isFinal: true, tokensPerSecond: 60.0);
    }

    final service = ChatService(streamProvider: mockStream);

    final events = <InferenceChunk>[];
    final completer = Completer<void>();

    final sub = service.chat('test', ModelTier.sentinel).listen((chunk) {
      events.add(chunk);
      if (chunk.isFinal) completer.complete();
    });

    // Wait until final chunk received or timeout.
    await completer.future.timeout(Duration(seconds: 1));
    await sub.cancel();

    expect(events.length, 2);
    expect(events[0].token, 'Hello');
    expect(events[1].token, 'World');
    expect(events.last.isFinal, true);
  });
}
