import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lumi/core/theme.dart';
import 'package:lumi/features/theme_showcase/theme_showcase.dart';

void main() {
  testWidgets('ThemeShowcase displays color swatches and text samples', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: getLumiTheme(), home: const ThemeShowcase()));

    // Verify color swatches exist
    final primaryFinder = find.byKey(const Key('swatch-primary'));
    final surfaceFinder = find.byKey(const Key('swatch-surface'));
    final outlineFinder = find.byKey(const Key('swatch-outlineVariant'));

    expect(primaryFinder, findsOneWidget);
    expect(surfaceFinder, findsOneWidget);
    expect(outlineFinder, findsOneWidget);

    // Inspect the Container widget color for primary
    final primaryWidget = tester.widget<Container>(primaryFinder);
    expect((primaryWidget.decoration == null && primaryWidget.color != null) ? primaryWidget.color : null, LumiColors.primary);

    // Verify text style samples exist and have expected font sizes (non-null)
    final displayFinder = find.byKey(const Key('text-displayLarge'));
    expect(displayFinder, findsOneWidget);
    final Text displayText = tester.widget(displayFinder);
    expect(displayText.style, isNotNull);
    expect(displayText.style?.fontSize, isNotNull);
  });
}
