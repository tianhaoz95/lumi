// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

/// Compatibility extension: provide withValues(opacity: double) to replace deprecated withOpacity
/// Implementation avoids calling deprecated getters by using the raw color value.
extension ColorValues on Color {
  /// Returns the color with the given opacity (0.0 - 1.0).
  Color withValues({double opacity = 1.0}) {
    final alpha = (opacity.clamp(0.0, 1.0) * 255).round() & 0xFF;
    final rgb = value & 0x00FFFFFF;
    return Color((alpha << 24) | rgb);
  }
}
