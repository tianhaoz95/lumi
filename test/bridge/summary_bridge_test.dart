import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/rig_bridge.dart';

void main() {
  test('fetchMonthlySummary returns shimbed summary', () async {
    final summary = await fetchMonthlySummary();
    expect(summary.totalExpenses, 1234.56);
    expect(summary.totalMiles, 120.0);
    expect(summary.estimatedDeduction, closeTo(80.40, 0.01));
  });
}
