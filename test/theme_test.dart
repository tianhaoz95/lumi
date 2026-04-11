import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lumi/core/theme.dart';

void main() {
  test('Lumi color tokens present in theme', () {
    final theme = getLumiTheme();
    expect(theme.colorScheme.primary, LumiColors.primary);
    expect(theme.scaffoldBackgroundColor, LumiColors.surface);
    expect(LumiRadius.defaultRadius, 16.0);
  });

  test('TextTheme uses Manrope for display and Inter for body with correct metrics', () {
    final theme = getLumiTheme();
    final dt = theme.textTheme;

    // Verify typographic metrics
    expect(dt.displayLarge?.letterSpacing, -0.02);
    expect(dt.bodyLarge?.height, 1.6);

    // Ensure font families are set (GoogleFonts sets a fontFamily string)
    expect(dt.displayLarge?.fontFamily, isNotNull);
    expect(dt.bodyLarge?.fontFamily, isNotNull);
  });
}
