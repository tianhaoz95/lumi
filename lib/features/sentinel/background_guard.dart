import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lumi/features/sentinel/notification_service.dart';

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

      // If the native side returned a report, attempt to parse and trigger a notification.
      try {
        Map<String, dynamic>? report;
        if (res == null) {
          report = null;
        } else if (res is String) {
          // Some bridges return JSON strings; attempt to parse
          try {
            report = Map<String, dynamic>.from(jsonDecode(res) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('[BackgroundGuard] failed to decode JSON string report: $e');
            report = null;
          }
        } else if (res is Map) {
          report = Map<String, dynamic>.from(res);
        }

        if (report != null) {
          final int untagged = (report['untagged_count'] is int) ? report['untagged_count'] as int : (report['untagged_count'] is num ? (report['untagged_count'] as num).toInt() : 0);
          final List<dynamic> missing = report['missing_days'] is List ? report['missing_days'] as List<dynamic> : <dynamic>[];
          final List<dynamic> incomplete = report['incomplete_mileage'] is List ? report['incomplete_mileage'] as List<dynamic> : <dynamic>[];

          if (untagged > 0 || missing.isNotEmpty || incomplete.isNotEmpty) {
            try {
              // Lazy initialize notification service and show alert
              final ns = await _ensureNotificationServiceInitialized();
              await ns.showSentinelAlert(report);
            } catch (e) {
              debugPrint('[BackgroundGuard] notification failed: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('[BackgroundGuard] parsing sentinel report failed: $e');
      }
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

  Future<NotificationService> _ensureNotificationServiceInitialized() async {
    // Lazy init to avoid pulling notification plugin into tests unnecessarily.
    try {
      final ns = NotificationService();
      await ns.initialize();
      return ns;
    } catch (e) {
      debugPrint('[BackgroundGuard] failed to init NotificationService: $e');
      rethrow;
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
