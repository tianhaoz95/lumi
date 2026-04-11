import 'dart:io';
import 'package:lumi/shared/bridge/bridge.dart' as bridge;

Future<void> main() async {
  final times = <int>[];
  for (var i = 0; i < 1000; i++) {
    final sw = Stopwatch()..start();
    await bridge.ping();
    sw.stop();
    times.add(sw.elapsedMicroseconds);
  }
  times.sort();
  final idx = (0.99 * times.length).ceil() - 1;
  final p99 = times[idx] / 1000.0; // ms
  print('p99_ms: $p99');
  if (p99 < 2.0) {
    print('Latency OK');
    exit(0);
  } else {
    print('Latency too high');
    exit(2);
  }
}
