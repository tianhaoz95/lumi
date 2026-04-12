import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_service.dart';
import 'package:lumi/shared/bridge/inference.dart' as bridge;

/// Provides a ChatService instance. In tests this can be overridden.
final chatServiceProvider = Provider<ChatService>((ref) {
  // Use the real FRB inferStream by default.
  return ChatService(
    streamProvider: ({required String prompt, required bridge.ModelTier modelTier}) {
      return bridge.inferStream(prompt: prompt, modelTier: modelTier);
    },
  );
});
