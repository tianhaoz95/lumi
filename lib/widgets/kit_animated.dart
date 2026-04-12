import 'package:flutter/material.dart';

/// A lightweight, asset-free Kit animation widget implementing four states:
/// Idle, Thinking, Found (one-shot), Alert (one-shot).
///
/// Public API: provide a [state] and optional [onFound] / [onAlert] callbacks.

enum KitState { idle, thinking, found, alert }

class KitAnimated extends StatefulWidget {
  // Preferred API: explicit state
  final KitState? state;
  // Backwards-compatible boolean used by older imports
  final bool? isProcessing;
  final double size;
  final double opacity;
  final VoidCallback? onFoundComplete;
  final VoidCallback? onAlertComplete;

  const KitAnimated({
    Key? key,
    this.state,
    this.isProcessing,
    this.size = 96.0,
    this.opacity = 0.07,
    this.onFoundComplete,
    this.onAlertComplete,
  }) : super(key: key);

  @override
  State<KitAnimated> createState() => _KitAnimatedState();
}

class _KitAnimatedState extends State<KitAnimated> with TickerProviderStateMixin {
  late AnimationController _breathController; // idle breathing
  late AnimationController _thinkingController; // lateral swipe
  late AnimationController _foundController; // one-shot
  late AnimationController _alertController; // one-shot

  KitState get _effectiveState => widget.state ?? (widget.isProcessing == true ? KitState.thinking : KitState.idle);

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _foundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _applyState(_effectiveState);
  }

  @override
  void didUpdateWidget(covariant KitAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEffective = oldWidget.state ?? (oldWidget.isProcessing == true ? KitState.thinking : KitState.idle);
    final newEffective = _effectiveState;
    if (oldEffective != newEffective) {
      _applyState(newEffective);
    }
  }

  void _applyState(KitState s) {
    // Reset one-shot controllers if switching away
    if (s != KitState.found) {
      _foundController.reset();
    }
    if (s != KitState.alert) {
      _alertController.reset();
    }

    switch (s) {
      case KitState.idle:
        if (!_breathController.isAnimating) _breathController.repeat();
        _thinkingController.stop();
        break;
      case KitState.thinking:
        if (!_thinkingController.isAnimating) _thinkingController.repeat();
        _breathController.repeat();
        break;
      case KitState.found:
        _foundController.forward().whenComplete(() {
          widget.onFoundComplete?.call();
          // return to idle after found animation
          _applyState(KitState.idle);
        });
        break;
      case KitState.alert:
        _alertController.forward().whenComplete(() {
          widget.onAlertComplete?.call();
          _applyState(KitState.idle);
        });
        break;
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _thinkingController.dispose();
    _foundController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a simple fox-like circle placeholder with animated transforms.
    return Opacity(opacity: widget.opacity, child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [ 
          // Idle breathing: subtle scale
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              final t = _breathController.value;
              final scale = 1.0 + 0.03 * (0.5 - (0.5 - (t - 0.5).abs()));
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _buildFoxBase(opacity: 0.1), // ghost background
          ),

          // Thinking lateral swipe overlay
          AnimatedBuilder(
            animation: _thinkingController,
            builder: (context, child) {
              final dx = 8.0 * (0.5 - (_thinkingController.value - 0.5));
              final opacity = widget.state == KitState.thinking ? 1.0 : 0.0;
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                ),
              );
            },
            child: _buildFoxBase(opacity: 0.6),
          ),

          // Found one-shot pop (scale + glow)
          AnimatedBuilder(
            animation: _foundController,
            builder: (context, child) {
              final v = _foundController.value;
              final scale = 1.0 + 0.25 * v;
              final opacity = v;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: _buildFoxBase(opacity: 1.0),
          ),

          // Alert one-shot: ear perk (a quick rotate on a small triangle)
          AnimatedBuilder(
            animation: _alertController,
            builder: (context, child) {
              final v = _alertController.value;
              final rotation = 0.2 * (v - 0.5);
              final opacity = v;
              return Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: child,
                ),
              );
            },
            child: _buildFoxBase(opacity: 1.0, color: Colors.amber),
          ),
        ],
      ),
    ));
  }

  Widget _buildFoxBase({double opacity = 1.0, Color? color}) {
    final baseColor = color ?? const Color(0xFF00464A);
    return Container(
      key: const Key('kit-fox-base'),
      width: widget.size * 0.9,
      height: widget.size * 0.9,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        color: Colors.white.withOpacity((opacity.clamp(0.0, 1.0))),
        size: widget.size * 0.45,
      ),
    );
  }
}
