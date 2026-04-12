import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Base text theme using Inter for body and labels with specified line height.
  final base = GoogleFonts.interTextTheme().copyWith(
    bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.6),
    bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.6),
    bodySmall: GoogleFonts.inter(fontSize: 12, height: 1.6),
    labelLarge: GoogleFonts.inter(fontSize: 14, height: 1.6),
    labelMedium: GoogleFonts.inter(fontSize: 13, height: 1.6),
    labelSmall: GoogleFonts.inter(fontSize: 12, height: 1.6),
  );

  // Apply Manrope to all headline/display/title styles to ensure consistent editorial typography.
  final textTheme = base.copyWith(
    displayLarge: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    displayMedium: GoogleFonts.manrope(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.02),
    headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.02),
    titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.02),
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
        // Use Manrope via google_fonts to ensure the font is loaded correctly for prominent buttons.
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
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
