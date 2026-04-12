import 'package:flutter/material.dart';

/// Lightweight KitAnimated widget with a compatibility-focused API.
/// Supports both the older `isProcessing` boolean and a richer `state` enum.
enum KitState { idle, thinking, found, alert }

class KitAnimated extends StatefulWidget {
  // Backwards-compatible boolean used in earlier commits
  final bool? isProcessing;
  // Preferred: explicit state
  final KitState? state;
  final double size;
  final double opacity;
  final VoidCallback? onFoundComplete;

  const KitAnimated({Key? key, this.isProcessing, this.state, this.size = 120.0, this.opacity = 0.07, this.onFoundComplete}) : super(key: key);

  @override
  State<KitAnimated> createState() => _KitAnimatedState();
}

class _KitAnimatedState extends State<KitAnimated> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scale;

  KitState get _effectiveState {
    if (widget.state != null) return widget.state!;
    if (widget.isProcessing == true) return KitState.thinking;
    return KitState.idle;
  }

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOut));
    if (_effectiveState == KitState.thinking) {
      _ctl.repeat(reverse: true);
    } else if (_effectiveState == KitState.found) {
      _playFoundOnce();
    }
  }

  @override
  void didUpdateWidget(covariant KitAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldState = oldWidget.state ?? (oldWidget.isProcessing == true ? KitState.thinking : KitState.idle);
    final newState = _effectiveState;
    if (oldState != newState) {
      if (newState == KitState.thinking) {
        if (!_ctl.isAnimating) _ctl.repeat(reverse: true);
      } else if (oldState == KitState.thinking && _ctl.isAnimating) {
        _ctl.stop();
        _ctl.reset();
      }

      if (newState == KitState.found) {
        _playFoundOnce();
      }
    }
  }

  Future<void> _playFoundOnce() async {
    try {
      await _ctl.forward(from: 0.0);
      // call completion callback if provided
      widget.onFoundComplete?.call();
      // reset to idle state
      if (mounted) {
        _ctl.reset();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _effectiveState;
    final scale = (state == KitState.thinking) ? _scale : AlwaysStoppedAnimation<double>(1.0);

    return Opacity(
      opacity: widget.opacity,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: AnimatedBuilder(
            animation: scale,
            builder: (context, child) {
              return Transform.scale(
                scale: (state == KitState.thinking) ? scale.value : 1.0,
                child: child,
              );
            },
            // Provide a stable key for older tests
            child: Icon(Icons.pets, key: const Key('kit-fox-base'), size: widget.size * 0.9, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}