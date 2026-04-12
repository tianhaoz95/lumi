import Flutter
import UIKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  var flutterEngine: FlutterEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Start a background FlutterEngine for native -> Dart callbacks (used by BGTask handlers).
    flutterEngine = FlutterEngine(name: "background")
    flutterEngine?.run()
    if let engine = flutterEngine {
      GeneratedPluginRegistrant.register(with: engine)
    }

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
      print("[BackgroundGuard] BGAppRefreshTask running — invoking Dart onHeartbeat")

      guard let engine = self.flutterEngine else {
        print("[BackgroundGuard] FlutterEngine not available")
        return
      }

      let channel = FlutterMethodChannel(name: "com.lumi/sentinel", binaryMessenger: engine.binaryMessenger)

      // Use a semaphore to bound wait time so the BGTask can finish within system limits.
      let sem = DispatchSemaphore(value: 0)

      channel.invokeMethod("onHeartbeat", arguments: ["taskId": task.identifier ?? "bg_app_refresh"]) { (result) in
        print("[BackgroundGuard] onHeartbeat result: \(String(describing: result))")
        sem.signal()
      }

      // Wait up to 25 seconds for Dart handler to respond; then continue and allow expiration handler to enforce limits.
      _ = sem.wait(timeout: .now() + 25)
    }

    task.expirationHandler = {
      queue.cancelAllOperations()
    }

    // Ensure the BGTask is marked completed after the operation finishes or is cancelled.
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
      print("[BackgroundGuard] BGProcessingTask running — invoking Dart onHeartbeat (processing)")

      guard let engine = self.flutterEngine else {
        print("[BackgroundGuard] FlutterEngine not available")
        return
      }

      let channel = FlutterMethodChannel(name: "com.lumi/sentinel", binaryMessenger: engine.binaryMessenger)
      let sem = DispatchSemaphore(value: 0)

      channel.invokeMethod("onHeartbeat", arguments: ["taskId": task.identifier ?? "bg_processing"]) { (result) in
        print("[BackgroundGuard] onHeartbeat (processing) result: \(String(describing: result))")
        sem.signal()
      }

      // Wait up to 60 seconds for longer processing, but avoid indefinite blocking.
      _ = sem.wait(timeout: .now() + 60)
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
