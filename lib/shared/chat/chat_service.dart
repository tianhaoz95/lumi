import 'package:lumi/shared/bridge/inference.dart' as bridge;

/// Re-exporting bridge types for convenience or defining wrappers if needed.
/// For Phase 2, we use the types directly from the FRB bridge.

typedef InferenceChunk = bridge.InferenceChunk;
typedef ModelTier = bridge.ModelTier;

/// Type for the underlying FRB stream provider.
typedef _StreamProvider = Stream<InferenceChunk> Function({required String prompt, required ModelTier modelTier});

/// ChatService exposes a simple API to request chat responses from the
/// inference backend.
class ChatService {
  final _StreamProvider _streamProvider;

  ChatService({required _StreamProvider streamProvider}) : _streamProvider = streamProvider;

  /// Legacy streaming API (uses underlying stream provider).
  Stream<InferenceChunk> chat(String prompt, ModelTier tier) => _streamProvider(prompt: prompt, modelTier: tier);

  /// Rig-backed agent chat entrypoint. By default delegates to the same
  /// stream provider as `chat`.
  Stream<InferenceChunk> agentChat(String prompt, ModelTier tier) => _streamProvider(prompt: prompt, modelTier: tier);
}
