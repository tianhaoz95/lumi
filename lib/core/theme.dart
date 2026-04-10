import 'package:flutter/material.dart';

class LumiColors {
  static const primary = Color(0xFF00464A);
  static const primaryContainer = Color(0xFF006064);
  static const surface = Color(0xFFF5FAFC);
  static const onSurface = Color(0xFF171C1E);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFE4E9EB);
  static const outlineVariant = Color(0xFFBEC8C9);
}

class LumiRadius {
  static const double defaultRadius = 16.0;
  static const double fullRadius = 9999.0;
}

ThemeData getLumiTheme() {
  return ThemeData(
    primaryColor: LumiColors.primary,
    scaffoldBackgroundColor: LumiColors.surface,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: LumiColors.primary,
      background: LumiColors.surface,
      surface: LumiColors.surfaceContainerLowest,
      onSurface: LumiColors.onSurface,
    ),
    textTheme: const TextTheme(),
  );
}
