import 'dart:ui';

import 'package:flutter/material.dart';

import 'lumi_button.dart';

/// LumiPrimaryButton: thin wrapper around existing LumiButton to provide a named API.
class LumiPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LumiPrimaryButton({Key? key, required this.child, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LumiButton(
      onPressed: onPressed,
      padding: padding,
      child: child,
    );
  }
}

/// LumiSecondaryButton: glassmorphism-styled secondary button with 40% white overlay and 12px blur.
class LumiSecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LumiSecondaryButton({Key? key, required this.child, this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24), this.radius = 9999.0}) : super(key: key);

  @override
  _LumiSecondaryButtonState createState() => _LumiSecondaryButtonState();
}

class _LumiSecondaryButtonState extends State<LumiSecondaryButton> {
  bool _pressed = false;
  bool _hover = false;

  double get _scale => _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

  static const Duration _animDuration = Duration(milliseconds: 300);
  static const Curve _animCurve = Curves.easeOut;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _scale,
          duration: _animDuration,
          curve: _animCurve,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.40),
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Color(0xFF171C1E), fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
                    child: Center(child: widget.child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// LumiTextAction: text-style action that applies the same "drifting" animation as other buttons.
class LumiTextAction extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const LumiTextAction({Key? key, required this.child, this.onPressed}) : super(key: key);

  @override
  _LumiTextActionState createState() => _LumiTextActionState();
}

class _LumiTextActionState extends State<LumiTextAction> {
  bool _pressed = false;
  bool _hover = false;

  double get _scale => _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

  static const Duration _animDuration = Duration(milliseconds: 300);
  static const Curve _animCurve = Curves.easeOut;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _scale,
          duration: _animDuration,
          curve: _animCurve,
          child: DefaultTextStyle(
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Preview widget for quick manual checks.
class LumiButtonsPreview extends StatelessWidget {
  const LumiButtonsPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LumiPrimaryButton(
          onPressed: () {},
          child: const Text('Primary'),
        ),
        const SizedBox(height: 12),
        LumiSecondaryButton(
          onPressed: () {},
          child: const Text('Secondary'),
        ),
      ],
    );
  }
}
