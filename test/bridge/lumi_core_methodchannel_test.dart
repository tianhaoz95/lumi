import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/shared/bridge/lumi_core_bridge.dart';
import 'package:lumi/shared/bridge/rig_bridge.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('LumiCoreBridge MethodChannel handler returns summary and rig_bridge uses it', () async {
    final channel = const MethodChannel('lumi_core_bridge');

    // Register a mock handler that returns a Map for get_summary
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'get_summary') {
        return <String, dynamic>{
          'total_expenses': 42.0,
          'total_miles': 10.0,
          'estimated_deduction': 6.7,
        };
      }
      if (methodCall.method == 'query_transactions') {
        return <Map<String, dynamic>>[
          {'id': '1', 'vendor': 'Test', 'category': 'test', 'amount': -1.0, 'date': '2026-04-01', 'is_tagged': false}
        ];
      }
      return null;
    });

    // Directly call LumiCoreBridge.getSummary via MethodChannel
    final map = await LumiCoreBridge.getSummary('this_month');
    expect(map['total_expenses'], 42.0);
    expect(map['total_miles'], 10.0);
    expect(map['estimated_deduction'], 6.7);

    // Now call the higher-level rig_bridge.fetchMonthlySummary which should use LumiCoreBridge and map to FinancialSummary
    final summary = await fetchMonthlySummary();
    expect(summary.totalExpenses, 42.0);
    expect(summary.totalMiles, 10.0);
    expect(summary.estimatedDeduction, closeTo(6.7, 1e-6));

    // Clean up the mock handler
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
