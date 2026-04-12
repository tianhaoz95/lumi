import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../core/theme.dart';
import '../../core/widgets/lumi_top_app_bar.dart';
import '../../shared/widgets/atmospheric_background.dart';
import '../../shared/widgets/kit_ghost.dart';
import '../../shared/widgets/kit_animated.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../shared/widgets/glass_modal.dart';
import '../../shared/widgets/tokens_overlay.dart';
import '../../shared/widgets/lumi_text_field.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../shared/chat/chat_service.dart';
import '../../shared/chat/chat_providers.dart';
import '../../core/model_router.dart';
import 'package:go_router/go_router.dart';
import '../chat/widgets/insight_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialChatParams;
  HomeScreen({Key? key, this.initialChatParams}) : super(key: key);

  static const _chatHint = 'Whisper to Lumi…';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Handle deep-linking params to prefill chat input when navigated via notification
    final params = widget.initialChatParams;
    if (params != null && params['openChat'] == true) {
      final prefill = params['prefill'] as String? ?? '';
      if (prefill.isNotEmpty) {
        // Defer to next frame so controller and focus are available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.text = prefill;
          try {
            FocusScope.of(context).requestFocus(_inputFocus);
          } catch (_) {}
        });
      }
    }
  }
  StreamSubscription<InferenceChunk>? _streamSub;
  bool _isStreaming = false;
  double? _tokensPerSecond;

  @override
  void dispose() {
    _controller.dispose();
    _streamSub?.cancel();
    super.dispose();
  }

  // Shows the add bottom sheet with Camera / Photo Library options.
  void _showAddSheet() async {
    final choice = await showGlassModalBottomSheet<String>(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.of(context).pop('camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Photo Library'),
            onTap: () => Navigator.of(context).pop('gallery'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    if (choice == null) return;

    // Placeholder handlers: integration with image picker / camera will be
    // implemented in subsequent roadmap items (3.1.3 / 3.1.4).
    if (choice == 'camera') {
      // TODO: open camera and pass bytes to Rust via FRB
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera selected (not yet implemented)')));
    } else if (choice == 'gallery') {
      // TODO: open gallery and pass bytes to Rust via FRB
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo Library selected (not yet implemented)')));
    }
  }

  void _send() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isStreaming) return;

    // Decide model tier for this prompt
    final selectedTier = ModelRouter.select(prompt);

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(author: _Author.user, text: prompt, modelTier: ModelTier.sentinel));
      // Add placeholder for Kit's streaming response (record the selected tier)
      _messages.add(_ChatMessage(author: _Author.kit, text: '', isStreaming: true, modelTier: selectedTier));
      _isStreaming = true;
      _tokensPerSecond = null;
    });

    _controller.clear();

    final chatService = ref.read(chatServiceProvider);
    // Use the Rig-backed agent chat entrypoint (agent_chat) when available.
    final stream = chatService.agentChat(prompt, selectedTier);

    _streamSub = stream.listen((chunk) {
      setState(() {
        final last = _messages.last;
        // Append token to last message text, preserving modelTier
        final updated = _ChatMessage(author: last.author, text: last.text + chunk.token, isStreaming: !chunk.isFinal, modelTier: last.modelTier);
        _messages[_messages.length - 1] = updated;
        // Update tokens per second metric for overlay (debug only)
        _tokensPerSecond = chunk.tokensPerSecond;
        if (chunk.isFinal) {
          _isStreaming = false;
          _tokensPerSecond = null;
        }
      });
    }, onError: (e) {
      setState(() {
        final last = _messages.last;
        _messages[_messages.length - 1] = _ChatMessage(author: last.author, text: 'Lumi is resting…', isStreaming: false, modelTier: last.modelTier);
        _isStreaming = false;
        _tokensPerSecond = null;
      });
    }, onDone: () {
      setState(() {
        _isStreaming = false;
        _tokensPerSecond = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumiColors.surface,
      body: Stack(
        children: [
          const AtmosphericBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top app bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: SizedBox(
                      // preserve similar vertical padding to previous implementation
                      height: kToolbarHeight + 24.0,
                      child: LumiTopAppBar(
                        title: Text('Lumi AI', style: Theme.of(context).textTheme.titleLarge),
                        actions: [
                          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
                        ],
                      ),
                    ),
                  ),
                ),

                // Chat area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _ChatArea(messages: _messages, isProcessing: _isStreaming),
                  ),
                ),

                const SizedBox(height: 84),
              ],
            ),
          ),

          // Input bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LumiCard(
                radius: 9999,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.add), onPressed: _showAddSheet, tooltip: 'Add'),
                    Expanded(
                      child: LumiTextField(
                        key: const Key('chat_input'),
                        controller: _controller,
                        hintText: HomeScreen._chatHint,
                        focusNode: _inputFocus,
                      ),
                    ),
                    IconButton(
                      key: const Key('send_button'),
                      icon: const Icon(Icons.send),
                      onPressed: _isStreaming ? null : _send,
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.mic), onPressed: () {}, tooltip: 'Voice'),
                  ],
                ),
              ),
            ),
          ),

          // Floating nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: FloatingNavBar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.dashboard)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.receipt_long)),
                IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.person)),
              ],
            ),
          ),

          // Dev overlay: show tokens_per_second while streaming (kDebugMode only)
          TokensOverlay(tokensPerSecond: _tokensPerSecond),
        ],
      ),
    );
  }
}

class _ChatArea extends StatelessWidget {
  final List<_ChatMessage> messages;
  final bool isProcessing;
  const _ChatArea({Key? key, required this.messages, required this.isProcessing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return Center(child: KitAnimated(isProcessing: isProcessing, opacity: 0.4, size: 160));

    return ListView.builder(
      itemCount: messages.length,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      itemBuilder: (context, index) {
        final m = messages[index];

        final bgColor = m.author == _Author.kit ? LumiColors.surfaceContainerLowest : LumiColors.surfaceContainerHigh;
        final textColor = LumiColors.onSurface;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: m.author == _Author.user ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // If Kit (assistant) message, show a small avatar + optional Auditor badge
              if (m.author == _Author.kit) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, size: 28, color: Colors.grey),
                      const SizedBox(height: 4),
                      if (m.modelTier == ModelTier.auditor)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: LumiColors.primary.withAlpha(31),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.shield, size: 12, color: Color(0xFF00464A)),
                              SizedBox(width: 4),
                              Text('Auditor', style: TextStyle(fontSize: 10, color: Color(0xFF00464A))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16.0)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Builder(builder: (context) {
                          try {
                            final parsed = jsonDecode(m.text);
                            if (parsed is Map && parsed.containsKey('insight_type')) {
                              return InsightCard.fromMap(Map<String, dynamic>.from(parsed));
                            }
                          } catch (_) {
                            // not JSON — fall through to plain text
                          }
                          return Text(m.text, style: TextStyle(color: textColor));
                        }),
                      ),
                      if (m.isStreaming) ...[
                        const SizedBox(width: 8),
                        // breathing dot
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _Author { kit, user }

class _ChatMessage {
  final _Author author;
  final String text;
  final bool isStreaming;
  final ModelTier modelTier;
  const _ChatMessage({required this.author, required this.text, this.isStreaming = false, this.modelTier = ModelTier.sentinel});
}
