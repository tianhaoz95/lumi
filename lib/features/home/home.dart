import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/atmospheric_background.dart';
import '../../shared/widgets/kit_ghost.dart';
import '../../shared/widgets/lumi_card.dart';
import '../../shared/widgets/lumi_text_field.dart';
import '../../widgets/floating_nav_bar.dart';

/// HomeScreen — implements Phase 1.4.1
/// - Glass top app bar
/// - Atmospheric background
/// - Kit ghost when empty
/// - Chat bubble list (mock)
/// - Floating chat input bar (pill)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const _chatHint = 'Whisper to Lumi…';

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
                // Top app bar (glassmorphism)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: LumiColors.surfaceContainerLowest.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Lumi AI', style: Theme.of(context).textTheme.titleLarge),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {},
                              tooltip: 'Search',
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => Navigator.of(context).pushNamed('/settings'),
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Expandable chat area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _ChatArea(),
                  ),
                ),

                // Spacer for input bar (input is positioned above nav)
                const SizedBox(height: 84),
              ],
            ),
          ),

          // Floating chat input bar (pinned above bottom nav)
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
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                      tooltip: 'Add',
                    ),
                    Expanded(
                      child: LumiTextField(
                        hintText: _chatHint,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                      tooltip: 'Voice',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating nav bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: FloatingNavBar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.dashboard)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.receipt_long)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatArea extends StatelessWidget {
  final List<_ChatMessage> messages = const [
    _ChatMessage(author: _Author.kit, text: 'Hello! I can help tag your receipts.'),
    _ChatMessage(author: _Author.user, text: 'Show my expenses for last month.'),
    _ChatMessage(author: _Author.kit, text: 'Sure — pulling up your spending summary…'),
  ];

  _ChatArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: KitGhost(opacity: 0.4, size: 160));
    }

    return ListView.builder(
      itemCount: messages.length,
      reverse: false,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      itemBuilder: (context, index) {
        final m = messages[index];
        final align = m.author == _Author.user ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        final bgColor = m.author == _Author.user ? LumiColors.primary : LumiColors.surfaceContainerLowest;
        final textColor = m.author == _Author.user ? Colors.white : LumiColors.onSurface;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            mainAxisAlignment: m.author == _Author.user ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(color: textColor),
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
  const _ChatMessage({required this.author, required this.text});
}
