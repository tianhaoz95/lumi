import Flutter
import UIKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 13.0, *) {
      // Register background task handlers
      BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.lumi.app.heartbeat", using: nil) { task in
        // Determine task type and handle appropriately.
        if let appRefreshTask = task as? BGAppRefreshTask {
          self.handleAppRefresh(task: appRefreshTask)
        } else if let processingTask = task as? BGProcessingTask {
          self.handleProcessing(task: processingTask)
        } else {
          task.setTaskCompleted(success: false)
        }
      }
      // Schedule initial tasks
      scheduleAppRefresh()
      scheduleProcessingIfEligible()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @available(iOS 13.0, *)
  func handleAppRefresh(task: BGAppRefreshTask) {
    // Reschedule next refresh
    scheduleAppRefresh()

    // Perform quick work — keep within the system time budget.
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    let op = BlockOperation {
      // TODO: invoke Flutter/Dart BackgroundGuard.onHeartbeat via MethodChannel or FRB bridge
      // Placeholder: simple print and complete task
      print("[BackgroundGuard] BGAppRefreshTask running (placeholder)")
    }

    task.expirationHandler = {
      queue.cancelAllOperations()
    }

    op.completionBlock = {
      task.setTaskCompleted(success: !op.isCancelled)
    }

    queue.addOperation(op)
  }

  @available(iOS 13.0, *)
  func handleProcessing(task: BGProcessingTask) {
    // Reschedule processing for future
    scheduleProcessingIfEligible()

    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    let op = BlockOperation {
      // TODO: perform longer Sentinel scan when device is charging.
      print("[BackgroundGuard] BGProcessingTask running (placeholder)")
    }

    task.expirationHandler = {
      queue.cancelAllOperations()
    }

    op.completionBlock = {
      task.setTaskCompleted(success: !op.isCancelled)
    }

    queue.addOperation(op)
  }

  @available(iOS 13.0, *)
  func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.lumi.app.heartbeat")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule app refresh: \(error)")
    }
  }

  @available(iOS 13.0, *)
  func scheduleProcessingIfEligible() {
    // Schedule a BGProcessingTask only if device likely to be charging soon / allowed by system.
    let request = BGProcessingTaskRequest(identifier: "com.lumi.app.heartbeat")
    request.requiresExternalPower = true
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 6) // 6 hours
    request.requiresNetworkConnectivity = false
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule processing task: \(error)")
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
