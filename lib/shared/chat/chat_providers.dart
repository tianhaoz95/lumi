import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'chat_service.dart';

/// Provides a ChatService instance. In tests this can be overridden.
final chatServiceProvider = Provider<ChatService>((ref) {
  // Default mock stream provider: emits characters as tokens with a short delay.
  Stream<InferenceChunk> mockStream({required String prompt, required ModelTier modelTier}) async* {
    if (prompt.isEmpty) return;
    final tokens = prompt.split(' ');
    for (var i = 0; i < tokens.length; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      yield InferenceChunk(token: '${tokens[i]}${i < tokens.length - 1 ? ' ' : ''}', isFinal: false, tokensPerSecond: 0.0);
    }
    // final marker
    yield InferenceChunk(token: '', isFinal: true, tokensPerSecond: 0.0);
  }

  return ChatService(streamProvider: ({required String prompt, required ModelTier modelTier}) => mockStream(prompt: prompt, modelTier: modelTier));
});
