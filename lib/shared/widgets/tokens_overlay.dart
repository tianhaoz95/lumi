import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'lumi_card.dart';

class TokensOverlay extends StatelessWidget {
  final double? tokensPerSecond;
  const TokensOverlay({Key? key, required this.tokensPerSecond}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || tokensPerSecond == null) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: LumiCard(
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text('TPS: ${tokensPerSecond!.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
