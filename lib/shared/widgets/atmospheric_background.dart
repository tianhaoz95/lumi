import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lumi/core/colors.dart';

/// AtmosphericBackground
/// - fixed positioned blurred orbs
/// - subtle grain overlay drawn by a CustomPainter
class AtmosphericBackground extends StatelessWidget {
  final bool showGrain;
  const AtmosphericBackground({Key? key, this.showGrain = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        key: const Key('atmospheric-orbs'),
        child: Stack(
          children: [
            // Large soft orbs positioned off-screen for atmospheric effect
            Positioned(
              left: -80,
              top: -60,
              child: _Orb(
                size: 260,
                colors: [Color(0xFFBEEFF0), Color(0x00BEEFF0)],
                opacity: 0.08,
              ),
            ),
            Positioned(
              right: -100,
              top: 40,
              child: _Orb(
                size: 200,
                colors: [Color(0xFF8AD3D7), Color(0x008AD3D7)],
                opacity: 0.06,
              ),
            ),
            Positioned(
              left: 40,
              bottom: -80,
              child: _Orb(
                size: 180,
                colors: [Colors.white, Color(0x00FFFFFF)],
                opacity: 0.03,
              ),
            ),
            // Grain overlay
            if (showGrain)
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _GrainPainter(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;
  const _Orb({Key? key, required this.size, required this.colors, required this.opacity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  static const int _seed = 12345;
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = LumiColors.onSurface.withOpacity(atmosphericGrainOpacity); // ignore: deprecated_member_use
    final rand = Random(_seed);
    // Number of grains scaled by area, clamped for performance
    final total = (size.width * size.height / 2000).clamp(100, 600).toInt();
    for (int i = 0; i < total; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      // Draw a 1x1 rect for a grain dot
      canvas.drawRect(Rect.fromLTWH(x, y, 1.0, 1.0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Public helpers for testing and verification
int computeGrainTotal(Size size) => (size.width * size.height / 2000).clamp(100, 600).toInt();

const double atmosphericGrainOpacity = 0.02;
const int atmosphericGrainSeed = 12345;

/// Paints the grain overlay into the provided [canvas] with deterministic seed.
void paintGrainToCanvas(Canvas canvas, Size size) {
  // reuse the private painter implementation
  const _GrainPainter painter = _GrainPainter();
  painter.paint(canvas, size);
}
