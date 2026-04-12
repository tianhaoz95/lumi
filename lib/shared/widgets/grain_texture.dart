import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GrainTexture extends StatelessWidget {
  final double opacity;
  const GrainTexture({Key? key, this.opacity = 0.03}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Opacity(
        opacity: 0.03,
        child: _GrainSvg(),
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
