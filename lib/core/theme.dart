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
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: LumiColors.primary,
    primaryContainer: LumiColors.primaryContainer,
    secondary: LumiColors.primaryContainer,
    background: LumiColors.surface,
    surface: LumiColors.surfaceContainerLowest,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: LumiColors.onSurface,
    onSurface: LumiColors.onSurface,
    onError: Colors.white,
    error: Colors.red,
    surfaceVariant: LumiColors.surfaceContainerHigh,
    outline: LumiColors.outlineVariant,
  );

  final textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    headlineLarge: TextStyle(fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleLarge: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.6),
    labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12, height: 1.6),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: LumiColors.primary,
    scaffoldBackgroundColor: LumiColors.surface,
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LumiColors.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(LumiRadius.defaultRadius)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: LumiColors.primary.withOpacity(0.4))),
    ),
  );
}
