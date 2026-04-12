import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// BatteryMonitor measures battery level before/after a work callback and
/// reports results to the native bridge for persistence in sentinel_logs.
class BatteryMonitor {
  static final BatteryMonitor _instance = BatteryMonitor._();
  BatteryMonitor._();
  factory BatteryMonitor() => _instance;

  final Battery _battery = Battery();
  static const MethodChannel _bridge = MethodChannel('lumi_core_bridge');

  /// Runs [work] while recording battery level before and after. Returns the
  /// result of [work]. Any exceptions from the bridge are caught and logged.
  Future<T> runWithBatteryLogging<T>(Future<T> Function() work, {Future<int> Function()? readBattery}) async {
    try {
      final reader = readBattery ?? _readBatteryLevelSafe;
      final int before = await reader();
      final T result = await work();
      final int after = await reader();
      final int delta = (before < 0 || after < 0) ? -1 : (after - before);

      // Fire-and-forget to native bridge to update last sentinel log with battery info.
      try {
        await _bridge.invokeMethod('update_last_sentinel_battery', {
          'battery_before': before,
          'battery_after': after,
          'battery_delta': delta,
        });
      } catch (e) {
        debugPrint('[BatteryMonitor] bridge update failed: $e');
      }

      return result;
    } catch (e) {
      debugPrint('[BatteryMonitor] runWithBatteryLogging error: $e');
      rethrow;
    }
  }

  Future<int> _readBatteryLevelSafe() async {
    try {
      final level = await _battery.batteryLevel;
      return level;
    } catch (e) {
      debugPrint('[BatteryMonitor] battery read failed: $e');
      return -1; // sentinel value when unavailable
    }
  }
}
