import 'package:flutter/material.dart';

import 'colors.dart';
export 'colors.dart';

ThemeData getLumiTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: LumiColors.primary,
    primaryContainer: LumiColors.primaryContainer,
    secondary: LumiColors.primaryContainer,
    // Using legacy color keys in ColorScheme for compatibility with older Flutter versions.
    // ignore: deprecated_member_use
    background: LumiColors.surface,
    // Primary surface token (kept as lowest container for now)
    surface: LumiColors.surfaceContainerLowest,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    // ignore: deprecated_member_use
    onBackground: LumiColors.onSurface,
    onSurface: LumiColors.onSurface,
    onError: Colors.white,
    error: Colors.red,
    // ignore: deprecated_member_use
    surfaceVariant: LumiColors.surfaceContainerHigh,
    outline: LumiColors.outlineVariant,
  );

  // Base text theme using Inter for body and labels with specified line height.
  final base = const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, height: 1.6),
    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.6),
    bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12, height: 1.6),
    labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.6),
    labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6),
    labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12, height: 1.6),
  );

  // Apply Manrope to all headline/display/title styles to ensure consistent editorial typography.
  // High-Low pairing implemented: display styles are intentionally large to create extreme scale contrast
  // with compact body text (Inter at 16sp). This enforces the "High-Low" editorial pairing described in DESIGN.md.
  final textTheme = base.copyWith(
    // High (display) — prominent, editorial-first sizes
    displayLarge: const TextStyle(fontFamily: 'Manrope', fontSize: 64, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    displayMedium: const TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    displaySmall: const TextStyle(fontFamily: 'Manrope', fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    // Low (headline/title) — scaled down relative to displays but still prominent
    headlineLarge: const TextStyle(fontFamily: 'Manrope', fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    headlineMedium: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    headlineSmall: const TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    // Titles closer to body scale
    titleLarge: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleMedium: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleSmall: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.02),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: LumiColors.primary,
    scaffoldBackgroundColor: LumiColors.surface,
    // Default body/label fontFamily is Inter. Headline/display/title styles explicitly use Manrope via GoogleFonts above.
    fontFamily: 'Inter',
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        // Use Manrope for button text style.
        textStyle: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LumiColors.surfaceContainerHigh,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide(color: LumiColors.outlineVariant.withOpacity(0.4), width: 2.0)), // ignore: deprecated_member_use
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide(color: colorScheme.error.withOpacity(0.4))), // ignore: deprecated_member_use
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LumiRadius.defaultRadius),
          borderSide: BorderSide(color: colorScheme.error.withOpacity(0.6), width: 2.0)), // ignore: deprecated_member_use
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.transparent,
      thickness: 0,
      space: 0,
    ),
  );
}
