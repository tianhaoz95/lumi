import 'package:flutter/material.dart';
import '../../../shared/widgets/lumi_card.dart';

/// Wrapper used by dashboard metrics to explicitly use the shared LumiCard
/// (glassmorphism parameters are defined in the shared widget).
class LumiGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final double opacity;
  final double blur;

  const LumiGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 16.0,
    this.opacity = 0.70,
    this.blur = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Delegate to the shared LumiCard to ensure a single source of truth
    return LumiCard(child: child, padding: padding, onTap: onTap, radius: radius, blur: blur, opacity: opacity);
  }
}
