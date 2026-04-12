/// Lightweight local definitions to avoid importing FRB-generated bindings
/// into test builds where generated code may require newer Dart features.
/// The production FRB bindings should provide identical types; use
/// dependency injection to pass the real stream provider at runtime.

/// Chunk of inference output sent over FRB to Dart.
class InferenceChunk {
  final String token;
  final bool isFinal;
  final double tokensPerSecond;

  const InferenceChunk({
    required this.token,
    required this.isFinal,
    required this.tokensPerSecond,
  });

  @override
  int get hashCode => token.hashCode ^ isFinal.hashCode ^ tokensPerSecond.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InferenceChunk &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          isFinal == other.isFinal &&
          tokensPerSecond == other.tokensPerSecond;
}

/// Abstract model tier used for routing decisions. Sentinel == E2B (lightweight),
/// Auditor == E4B (heavy-weight analysis).
enum ModelTier { sentinel, auditor }

/// Type for the underlying FRB stream provider.
typedef _StreamProvider = Stream<InferenceChunk> Function({required String prompt, required ModelTier modelTier});

/// ChatService exposes a simple API to request chat responses from the
/// inference backend. The `streamProvider` is injectable for unit tests
/// and for environments where FRB bindings are not available.
class ChatService {
  final _StreamProvider _streamProvider;

  ChatService({_StreamProvider? streamProvider}) : _streamProvider = streamProvider ?? _defaultNotImplemented;

  /// Legacy streaming API (uses underlying stream provider).
  Stream<InferenceChunk> chat(String prompt, ModelTier tier) => _streamProvider(prompt: prompt, modelTier: tier);

  /// Rig-backed agent chat entrypoint. By default delegates to the same
  /// stream provider as `chat`. Production builds can override the provider
  /// to call the FRB `agent_chat` binding which emits agent-aware chunks.
  Stream<InferenceChunk> agentChat(String prompt, ModelTier tier) => _streamProvider(prompt: prompt, modelTier: tier);
}

Stream<InferenceChunk> _defaultNotImplemented({required String prompt, required ModelTier modelTier}) {
  throw UnsupportedError('FRB inferStream not available. Provide a streamProvider when constructing ChatService.');
}
