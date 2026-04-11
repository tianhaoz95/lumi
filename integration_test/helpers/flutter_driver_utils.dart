// Dev-only test helper for pumping until a Finder resolves.
// Location prescribed by roadmap: integration_test/helpers/flutter_driver_utils.dart

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

/// Pumps frames until [finder] is present in the widget tree or [timeout]
/// elapses. Throws [TimeoutException] when the finder is not found within
/// [timeout].
Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final deadline = DateTime.now().add(timeout);
  // First quick check without advancing time
  if (finder.evaluate().isNotEmpty) return;

  while (DateTime.now().isBefore(deadline)) {
    // Allow animations/timers to advance a little
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }

  throw TimeoutException('pumpUntilFound: Finder not found within $timeout');
}
