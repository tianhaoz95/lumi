import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/features/sentinel/battery_monitor.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;

  const MethodChannel bridge = MethodChannel('lumi_core_bridge');

  test('BatteryMonitor records before/after and reports to bridge', () async {
    int callIndex = 0;
    Future<int> fakeReader() async {
      callIndex += 1;
      return callIndex == 1 ? 50 : 52;
    }

    final List<MethodCall> calls = [];

    binding.defaultBinaryMessenger.setMockMethodCallHandler(bridge, (MethodCall methodCall) async {
      calls.add(methodCall);
      return null;
    });

    final result = await BatteryMonitor().runWithBatteryLogging<String>(() async => 'ok', readBattery: fakeReader);
    expect(result, 'ok');

    expect(calls.length, 1);
    expect(calls[0].method, 'update_last_sentinel_battery');
    final args = Map<String, dynamic>.from(calls[0].arguments as Map<dynamic, dynamic>);
    expect(args['battery_before'], 50);
    expect(args['battery_after'], 52);
    expect(args['battery_delta'], 2);

    // clean up mock
    binding.defaultBinaryMessenger.setMockMethodCallHandler(bridge, null);
  });
}
