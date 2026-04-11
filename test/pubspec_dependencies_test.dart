import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('pubspec contains image_picker and camera dependencies', () async {
    final file = File('pubspec.yaml');
    final content = await file.readAsString();
    expect(content.contains('image_picker'), isTrue,
        reason: 'image_picker should be listed in pubspec.yaml');
    expect(content.contains('camera:'), isTrue,
        reason: 'camera should be listed in pubspec.yaml');
  });
}
