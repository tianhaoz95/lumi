import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A glassmorphism card used across the app.
///
/// Usage: LumiCard(child: Text('...'))
class LumiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final double blur;
  final double opacity;

  const LumiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = LumiRadius.defaultRadius,
    this.blur = 24.0,
    this.opacity = 0.70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: LumiColors.onSurface.withAlpha((0.04 * 255).round()),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: LumiColors.surfaceContainerLowest.withAlpha((opacity * 255).round()),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
