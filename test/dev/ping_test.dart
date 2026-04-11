import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/bridge.dart' as bridge;

void main() {
  test('ping returns pong', () async {
    final res = await bridge.ping();
    expect(res, 'pong');
  });
}
