import 'package:flutter/material.dart';

/// KitGhost: a subtle, configurable ghost mascot widget for Lumi.
///
/// - opacity: overall widget opacity (0.0 - 1.0). Default: 0.07 (7%).
/// - size: icon size in logical pixels. Default: 120.
/// - color: optional tint color; if null, icon uses onSurface with grayscale filter.
class KitGhost extends StatelessWidget {
  final double opacity;
  final double size;
  final Color? color;

  const KitGhost({
    Key? key,
    this.opacity = 0.07,
    this.size = 120.0,
    this.color,
  }) : super(key: key);

  // Grayscale color matrix (desaturate)
  static const List<double> _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.onSurface.withOpacity(0.6); // ignore: deprecated_member_use

    Widget icon = Icon(
      Icons.pets,
      size: size,
      color: iconColor,
    );

    // Apply grayscale filter when no explicit color is provided to give ghost effect
    if (color == null) {
      icon = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
        child: icon,
      );
    }

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Center(
        child: Semantics(
          label: 'Kit the Fox ghost',
          child: icon,
        ),
      ),
    );
  }
}
