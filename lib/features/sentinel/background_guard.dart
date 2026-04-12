import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';

class BackgroundGuard {
  static final BackgroundGuard _instance = BackgroundGuard._();
  BackgroundGuard._();
  factory BackgroundGuard() => _instance;

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

    debugPrint('[BackgroundGuard] initialized (minInterval=60)');
  }

  void _onBackgroundFetch(String taskId) async {
    debugPrint('[BackgroundGuard] onFetch: $taskId');
    // TODO: call FRB run_sentinel_scan() when available and handle results.

    // Always signal finish to the native layer.
    BackgroundFetch.finish(taskId);
  }

  void _onBackgroundFetchTimeout(String taskId) {
    debugPrint('[BackgroundGuard] onTimeout: $taskId');
    BackgroundFetch.finish(taskId);
  }

  // Headless tasks receive a HeadlessTask instance in recent plugin versions.
  static void _headlessTask(HeadlessTask task) async {
    try {
      debugPrint('[BackgroundGuard] headlessTask: ' + task.taskId);
      // TODO: call FRB run_sentinel_scan() and persist logs to sentinel_logs table.
    } catch (e) {
      debugPrint('[BackgroundGuard] headlessTask error: $e');
    } finally {
      BackgroundFetch.finish(task.taskId);
    }
  }
}
