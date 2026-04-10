import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lumi/core/theme.dart';

void main() {
  test('LumiRadius constants', () {
    expect(LumiRadius.defaultRadius, 16.0);
    expect(LumiRadius.fullRadius, 9999.0);
  });

  testWidgets('Theme uses LumiRadius.defaultRadius in input border', (WidgetTester tester) async {
    final theme = getLumiTheme();
    final border = theme.inputDecorationTheme.border as OutlineInputBorder;
    final borderRadius = border.borderRadius as BorderRadius;
    // check top-left x value as representative
    expect(borderRadius.topLeft.x, LumiRadius.defaultRadius);
  });
}
