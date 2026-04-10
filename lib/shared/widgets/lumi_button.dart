import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// LumiButton: primary CTA with full-pill shape, gradient, and scale animations
class LumiButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;

  const LumiButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  }) : super(key: key);

  @override
  _LumiButtonState createState() => _LumiButtonState();
}

class _LumiButtonState extends State<LumiButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _hover = false;

  double get _scale => _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

  static const Duration _animDuration = Duration(milliseconds: 150);
  static const Curve _animCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? LinearGradient(
      colors: [LumiColors.primary, LumiColors.primaryContainer],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      transform: const GradientRotation(135 * 3.14159265 / 180),
    );

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
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(LumiRadius.fullRadius),
              boxShadow: [
                BoxShadow(
                  color: LumiColors.onSurface.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
