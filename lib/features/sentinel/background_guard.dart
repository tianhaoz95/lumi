import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BackgroundGuard {
  static final BackgroundGuard _instance = BackgroundGuard._();
  BackgroundGuard._();
  factory BackgroundGuard() => _instance;

  static const MethodChannel _channel = MethodChannel('com.lumi/sentinel');

  /// Initialize BackgroundFetch for Android/iOS with a 60-minute interval.
  Future<void> initialize() async {
    // Configure BackgroundFetch with a 60-minute minimum interval.
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 60, // minutes
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    // Register the headless task for post-termination execution.
    BackgroundFetch.registerHeadlessTask(_headlessTask);

    // Wire native -> Dart bridge for iOS BGTask and other native triggers.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onHeartbeat') {
        final args = call.arguments as Map<dynamic, dynamic>?;
        final taskId = args != null && args['taskId'] != null ? '${args['taskId']}' : 'native_bg';
        // Reuse the same handler to perform work and signal completion.
        _onBackgroundFetch(taskId);
        return true;
      }
      return null;
    });

    debugPrint('[BackgroundGuard] initialized (minInterval=60)');
  }

  Future<void> _onBackgroundFetch(String taskId) async {
    debugPrint('[BackgroundGuard] onFetch: $taskId');
    // Attempt to invoke native/rust sentinel scan via FRB bridge. If bindings are not
    // yet generated, catch and log the error for reviewer triage.
    try {
      final res = await MethodChannel('lumi_core_bridge').invokeMethod<dynamic>('run_sentinel_scan');
      debugPrint('[BackgroundGuard] run_sentinel_scan result: $res');
    } catch (e) {
      debugPrint('[BackgroundGuard] run_sentinel_scan failed: $e');
    }

    // Always signal finish to the native layer if BackgroundFetch plugin is active.
    try {
      BackgroundFetch.finish(taskId);
    } catch (e) {
      debugPrint('[BackgroundGuard] finish failed: $e');
    }
  }

  void _onBackgroundFetchTimeout(String taskId) {
    debugPrint('[BackgroundGuard] onTimeout: $taskId');
    try {
      BackgroundFetch.finish(taskId);
    } catch (e) {
      debugPrint('[BackgroundGuard] finish timeout failed: $e');
    }
  }

  // Headless tasks receive a HeadlessTask instance in recent plugin versions.
  static void _headlessTask(HeadlessTask task) async {
    try {
      debugPrint('[BackgroundGuard] headlessTask: ' + task.taskId);
      try {
        final res = await MethodChannel('lumi_core_bridge').invokeMethod<dynamic>('run_sentinel_scan');
        debugPrint('[BackgroundGuard] headless run_sentinel_scan result: $res');
      } catch (e) {
        debugPrint('[BackgroundGuard] headless run_sentinel_scan failed: $e');
      }
    } catch (e) {
      debugPrint('[BackgroundGuard] headlessTask error: $e');
    } finally {
      try {
        BackgroundFetch.finish(task.taskId);
      } catch (e) {
        debugPrint('[BackgroundGuard] headless finish failed: $e');
      }
    }
  }
}
