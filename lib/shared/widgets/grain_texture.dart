import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Test environment detection: when running `flutter test`, Dart sets
// the `FLUTTER_TEST` environment constant. In that environment
// skip loading the SVG to avoid flutter_svg filter parsing warnings.
const bool _isTesting = bool.fromEnvironment('FLUTTER_TEST');

class GrainTexture extends StatelessWidget {
  final double opacity;
  const GrainTexture({Key? key, this.opacity = 0.03}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_isTesting) {
      // Provide a lightweight placeholder during tests to avoid
      // flutter_svg parsing of unsupported filters (feTurbulence).
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: const _GrainSvg(),
      ),
    );
  }
}

class _GrainSvg extends StatelessWidget {
  const _GrainSvg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'design/assets/grain.svg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
    );
  }
}
