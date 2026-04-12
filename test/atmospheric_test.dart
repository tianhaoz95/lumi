import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/widgets/atmospheric_background.dart';

void main() {
  test('computeGrainTotal uses expected bounds', () {
    final size = Size(300, 800);
    final total = computeGrainTotal(size);
    expect(total >= 100 && total <= 600, isTrue);
  });

  test('paintGrainToCanvas does not throw and exposes opacity constant', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(200, 400);
    expect(() => paintGrainToCanvas(canvas, size), returnsNormally);
    expect(atmosphericGrainOpacity, closeTo(0.02, 1e-9));
  });
}
