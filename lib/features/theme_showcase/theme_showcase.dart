import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/lumi_top_app_bar.dart';

class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: LumiTopAppBar(title: const Text('Theme Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color Tokens', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _colorSwatch('primary', LumiColors.primary, const Key('swatch-primary')),
                _colorSwatch('primaryContainer', LumiColors.primaryContainer, const Key('swatch-primaryContainer')),
                _colorSwatch('surface', LumiColors.surface, const Key('swatch-surface')),
                _colorSwatch('onSurface', LumiColors.onSurface, const Key('swatch-onSurface')),
                _colorSwatch('surfaceContainerLowest', LumiColors.surfaceContainerLowest, const Key('swatch-surfaceContainerLowest')),
                _colorSwatch('surfaceContainerHigh', LumiColors.surfaceContainerHigh, const Key('swatch-surfaceContainerHigh')),
                _colorSwatch('outlineVariant', LumiColors.outlineVariant, const Key('swatch-outlineVariant')),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Text Styles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _textSample('displayLarge', textTheme.displayLarge, const Key('text-displayLarge')),
            const SizedBox(height: 8),
            _textSample('headlineLarge', textTheme.headlineLarge, const Key('text-headlineLarge')),
            const SizedBox(height: 8),
            _textSample('titleLarge', textTheme.titleLarge, const Key('text-titleLarge')),
            const SizedBox(height: 8),
            _textSample('bodyLarge', textTheme.bodyLarge, const Key('text-bodyLarge')),
            const SizedBox(height: 8),
            _textSample('labelSmall', textTheme.labelSmall, const Key('text-labelSmall')),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(String name, Color color, Key key) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(key: key, width: 64, height: 40, color: color),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _textSample(String name, TextStyle? style, Key key) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(name, key: key, style: style)),
        const SizedBox(width: 12),
        Text('${(style?.fontSize ?? 0).toStringAsFixed(0)}px', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
