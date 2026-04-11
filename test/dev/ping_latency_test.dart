import 'dart:async';
import 'package:test/test.dart';
import 'package:lumi/shared/bridge/bridge.dart' as bridge;

void main() {
  test('ping latency p99 < 2ms over 1000 iterations', () async {
    final times = <int>[];
    for (var i = 0; i < 1000; i++) {
      final sw = Stopwatch()..start();
      await bridge.ping();
      sw.stop();
      times.add(sw.elapsedMicroseconds); // microseconds
    }
    times.sort();
    final idx = (0.99 * times.length).ceil() - 1;
    final p99 = times[idx] / 1000.0; // milliseconds
    print('p99_ms: $p99');
    expect(p99, lessThan(2.0));
  }, timeout: Timeout(Duration(seconds: 20)));
}
