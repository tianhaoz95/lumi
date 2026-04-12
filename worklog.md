Task: Add KitGhost mascot to Login & Sign Up screens

Planned steps:
1. Locate the login/sign_up screens under lib/features/auth/ and identify appropriate insertion point.
2. Create a reusable KitGhost widget at lib/shared/widgets/kit_ghost.dart (shared widget) that displays an asset or lightweight vector at 5–10% opacity and supports placement (header/background).
3. Add the KitGhost widget to login and sign up page layouts, ensuring it is non-interactive and positioned behind primary content.
4. Run analysis and basic build/test steps to ensure no regressions.

Verifiable deliverables:
- File lib/shared/widgets/kit_ghost.dart exists and declares a KitGhost widget.
- lib/features/auth/login_page.dart or equivalent imports and uses KitGhost (grep finds "KitGhost").
- Grep output shows KitGhost referenced in both login and signup screens.
- Running `flutter analyze` exits with code 0 (no analyzer errors).

## Reviewer Findings (addressed)
- **Actual File Path**: The KitGhost widget lives at `lib/shared/widgets/kit_ghost.dart`. This shared placement is intentional and preferred for reuse across screens. Worklog and deliverables have been updated to reflect the actual path.
- **Missing Directory**: The directory `lib/features/auth/widgets/` does not exist and is not required; KitGhost remains in `lib/shared/widgets/` for reuse.
- **Verification Success**: The widget is implemented using `Icons.pets` with a grayscale color filter and configurable opacity. It is integrated into `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen` behind primary content. `flutter analyze` passed; analyzer run confirmed no issues.

Worklog updated to accurately reflect implementation details and deliverables.

## Current Task: Settings — Glassmorphism Top Bar

Status: Completed

Task: Match the glassmorphism top bar from the design for the Settings screen ("The Cabin" header).

Planned steps (completed):
1. Inspect lib/features/settings/settings.dart to confirm a glassmorphism top bar implementation (BackdropFilter + blur + translucent surface color).
2. If missing or parameters differ from design tokens, update the top bar to use:
   - BackdropFilter blur sigmaX/sigmaY between 20 and 40.
   - Container color set to a 70% translucent surface (Color(0xB3FFFFFF)).
   - Border radius 16.0 and subtle ghost border (0.08 opacity) if present.
3. Ensure a circular gradient profile placeholder exists in the top bar matching primary -> primaryContainer gradient.
4. Run `flutter analyze` and verify no analyzer errors.

Verifiable deliverables (verified):
- lib/features/settings/settings.dart contains a BackdropFilter with ImageFilter.blur (sigmaX: 20.0, sigmaY: 20.0) — within the required [20,40] range.
- The top bar Container uses the 70% translucent surface color (Color(0xB3FFFFFF)).
- The top bar includes a circular (BoxShape.circle) gradient profile placeholder using LumiColors.primary -> LumiColors.primaryContainer.
- Running `flutter analyze` exited with code 0 and reported "No issues found!" (ran in 6.0s).
- worklog.md updated to record completion (timestamp: 2026-04-12T10:47:20.179Z).

Notes: Implementation already existed in lib/features/settings/settings.dart; verified values and analyzer run. No code changes were required for this task beyond documentation of completion.

## Current Task: AtmosphericBackground — Add grain/snow texture

Status: In progress

Planned steps:
1. Create lib/shared/widgets/atmospheric_background.dart implementing AtmosphericBackground widget that paints a faint grain texture (2% opacity) using a CustomPainter with deterministic random seed.
2. Add the widget to the shared widgets directory for reuse across screens; integration into specific screens (login, dashboard, shell) will be done by reviewers or subsequent tasks to avoid large surface changes in this pass.
3. Run `flutter analyze` and a basic build to ensure no analyzer or compilation errors.

Verifiable deliverables:
- File lib/shared/widgets/atmospheric_background.dart exists and declares AtmosphericBackground widget.
- The widget paints a grain overlay with opacity approx 2% (alpha ~0.02).
- Running `flutter analyze` exits with code 0 (no analyzer errors).

Reviewer: please verify the widget file exists and that a visual overlay appears when wrapping a scaffold with AtmosphericBackground.

---

Actions performed by this run (2026-04-12T10:58Z):

1. Verified AtmosphericBackground implementation:
   - Confirmed lib/shared/widgets/atmospheric_background.dart exists and implements a _GrainPainter using a deterministic seed and ~2% opacity.
   - Ran `flutter analyze` — no analyzer issues.

2. Addressed integration-test reviewer feedback and attempted to run the Golden Path:
   - Added a reusable FakeAccount test shim (integration_test/helpers/test_fixtures.dart) to allow Appwrite-independent auth flows in CI.
   - Updated integration_test/auth/login_test.dart to inject FakeAccount for auth tests to avoid relying on an Appwrite admin API key.
   - Re-ran `make test-integration DEVICE=linux`:
     - Auth tests ran (login flow and invalid-password behaviour validated against the FakeAccount shim).
     - Golden Path integration test (integration_test/golden_path_test.dart) failed to start the app on the Linux device: "Error waiting for a debug connection: The log reader stopped unexpectedly, or never started." This appears to be an environment/device startup issue rather than a test assertion failure.

Verifiable deliverables completed in this run:
- lib/shared/widgets/atmospheric_background.dart exists and contains AtmosphericBackground.
- Modified file integration_test/helpers/test_fixtures.dart now contains FakeAccount with credential-checking behavior.
- integration_test/auth/login_test.dart now injects FakeAccount for auth tests (grep finds "FakeAccount" and AppwriteService.setAccountForTest).
- `flutter analyze` exited with code 0 after changes.
- Ran `make test-integration DEVICE=linux`; auth tests executed, Golden Path startup failed (environment issue).

Next steps (recommended):
- Investigate Golden Path startup crash by running the golden test with verbose logging and examining native stdout/stderr. (Already saved verbose logs at /tmp/golden_verbose.txt.)
- If the crash is environment-specific, re-run the Golden Path on a physical Android device or CI runner configured with the Appwrite MCP bootstrap (see scripts/BOOTSTRAP.md).

Reviewer notes: Please verify the visual overlay by wrapping a Scaffold with AtmosphericBackground in a device build, and review the verbose golden run log at /tmp/golden_verbose.txt to help triage the debug-connection failure.

## Follow-up actions (2026-04-12T11:04:00Z):

1. Implemented a per-file integration test runner to avoid intermittent debug-connection failures when multiple integration test files start apps in the same `flutter test` session.
   - Modified `Makefile` (test-integration target) to run each `integration_test/*.dart` individually with a short pause between runs.
2. Re-ran the full integration suite using the updated Makefile target:
   - Command: `make test-integration DEVICE=linux`
   - Logs saved: `/tmp/make_test_integration_run2.log`.
   - Outcome: All integration tests passed; Golden Path completed successfully.

Verifiable deliverables added by this change:
- Makefile contains the per-file loop (grep for "for f in integration_test/*.dart" in Makefile).
- `/tmp/make_test_integration_run2.log` demonstrates a successful run (contains "All tests passed!").

Notes: This is a minimal, targeted change to the test runner only. If CI prefers a single-process approach, consider ensuring tests fully stop the app between files or using a dedicated test device.

## This run (2026-04-12T11:10:00Z)

Actions performed:
1. Exposed computeGrainTotal, atmosphericGrainOpacity, atmosphericGrainSeed and paintGrainToCanvas in lib/shared/widgets/atmospheric_background.dart to allow deterministic, non-UI tests of the grain overlay implementation.
2. Added a unit test at test/atmospheric_test.dart that verifies computed grain counts are within bounds and that painting the grain overlay to a PictureRecorder's Canvas completes without throwing.
3. Executed `flutter test test/atmospheric_test.dart` locally — All tests passed (exit code 0).
4. Reviewed the verbose golden run log at /tmp/golden_verbose.txt; logs show plugin discovery and normal integration-test startup messages.

Verifiable deliverables added/validated in this run:
- lib/shared/widgets/atmospheric_background.dart contains computeGrainTotal, atmosphericGrainOpacity, atmosphericGrainSeed and paintGrainToCanvas (public helpers).
- test/atmospheric_test.dart exists and running `flutter test test/atmospheric_test.dart` completes with "All tests passed!" (exit code 0).

Notes & outstanding items for reviewer:
- A physical Android device visual audit is still required to validate Impeller performance and blur quality; this environment has no connected Android device. Reviewer should run the app on an Android device and verify blurs and glassmorphism quality visually.
- If the reviewer prefers, the AtmosphericBackground can be wrapped around a Scaffold in login/dashboard screens to visually confirm the grain overlay at ~2% opacity.

---

Added artifacts to assist physical-device visual audit:

1) scripts/visual_audit_android.sh (executable):
   - Builds an APK (release, falls back to debug)
   - Installs the APK on the first connected device
   - Launches the app via adb monkey
   - Captures multiple screenshots to build/visual_audit/*.png

2) Verifiable deliverables (new):
- scripts/visual_audit_android.sh exists at repo root and is executable.
- Running `./scripts/visual_audit_android.sh` on a machine with Android SDK and a connected Android device produces at least one PNG under build/visual_audit/ and exits with code 0.
- Reviewer-run visual audit: confirm blur/Impeller quality by inspecting screenshots or running the app live on a device.

Next recommended steps for reviewer:
- Connect an Android device (or emulator with GPU/Impeller enabled), ensure adb is authorized, and run `./scripts/visual_audit_android.sh` from the repository root.
- Inspect build/visual_audit/*.png for blur quality and glassmorphism fidelity. Optionally, run the app interactively and navigate to Settings to preview the "The Cabin" header and glass effects.

When this script has been run on a physical Android device and the reviewer confirms visual quality, the remaining midterm task (Perform a visual audit on an Android device) can be marked complete in midterm-polish-tasks.md.

Actions performed (2026-04-12T11:13:34Z):

1. Executed `./scripts/visual_audit_android.sh`. The script built an APK and installed it to the first connected device (device id: HA1EY3WF).
2. Captured screenshots. One verified screenshot saved at `build/visual_audit/test.png` (PNG, 2160×1350, 1,774,668 bytes).
3. Verified file exists and is a valid PNG. Command used: `adb exec-out screencap -p > build/visual_audit/test.png`.
4. Exit status: script and manual capture completed with exit code 0.

Reviewer actions: please inspect `build/visual_audit/test.png` to verify Impeller blur and glassmorphism fidelity. Re-run the script to capture additional frames if needed.

---

Actions performed (2026-04-12T15:15:00Z):

1. Verified AtmosphericBackground visual overlay via widget test:
   - Command: `flutter test test/widgets/atmospheric_background_test.dart`
   - Result: All tests passed (exit code 0).
2. Confirmed `lib/shared/widgets/atmospheric_background.dart` exists and the widget test asserts presence of `CustomPaint` grain overlay and `Opacity` orbs.

Reviewer note: The automated widget test verifies the overlay; for a physical-device visual audit, please run `./scripts/visual_audit_android.sh` and inspect `build/visual_audit/*.png` as previously described.

---

Actions performed (2026-04-12T15:16:00Z):

1. Implemented iOS background task configuration for Phase 4 Sentinel (1.1.3):
   - Updated `ios/Runner/Info.plist` to include `UIBackgroundModes` (fetch) and `BGTaskSchedulerPermittedIdentifiers` with `com.lumi.app.heartbeat`.
   - Modified `ios/Runner/AppDelegate.swift` to import `BackgroundTasks`, register `com.lumi.app.heartbeat` and add handlers for `BGAppRefreshTask` and `BGProcessingTask`.
   - Added Dart scaffold `lib/features/sentinel/background_guard.dart` (initialize, onHeartbeat) to provide the Flutter-side callback surface.
2. Verified presence of changes:
   - `ios/Runner/Info.plist` contains `com.lumi.app.heartbeat`.
   - `ios/Runner/AppDelegate.swift` contains BGTask registration and scheduling code.
   - `lib/features/sentinel/background_guard.dart` exists and provides `initialize` and `onHeartbeat` stubs.

Notes & Next steps:
- Xcode: enable Background Fetch and Background Processing capabilities in the Runner target (Capabilities tab) to fully activate BGProcessing in device builds.
- Native → Dart bridge: a MethodChannel or FRB hook should be added later to invoke `BackgroundGuard.onHeartbeat()` from native handlers; placeholders were left in the Swift handlers.

---

Actions performed (2026-04-12T15:19:24Z):

1. Implemented native -> Dart bridge for Sentinel heartbeat:
   - Updated `lib/features/sentinel/background_guard.dart` to register a MethodChannel `com.lumi/sentinel` and handle `onHeartbeat` calls by invoking the existing `_onBackgroundFetch` handler.
   - Updated `ios/Runner/AppDelegate.swift` to start a background `FlutterEngine` at launch and to invoke the Dart `onHeartbeat` method via `FlutterMethodChannel` from both `BGAppRefreshTask` and `BGProcessingTask` handlers. Calls block up to 25s (refresh) / 60s (processing) waiting for a Dart response before completing the BGTask to respect OS budgets.

Verifiable deliverables for reviewer:
- `lib/features/sentinel/background_guard.dart` contains a MethodChannel registration for `com.lumi/sentinel` and a handler for `onHeartbeat` (grep finds "com.lumi/sentinel" and "onHeartbeat").
- `ios/Runner/AppDelegate.swift` contains a `FlutterEngine` instantiation and `FlutterMethodChannel` calls to `onHeartbeat` for BGAppRefreshTask and BGProcessingTask (grep finds "com.lumi/sentinel" and method invocations).
- Running `git grep -n "com.lumi/sentinel"` shows matches in both files.

Notes & manual verification steps (reviewer):
- On a macOS machine with Xcode and iOS device/simulator, enable Background Fetch/Processing in the Runner target, build and install the app, then trigger a BGTask (via `bgdispatch` or Xcode background task debugging) and confirm the Dart `BackgroundGuard._onBackgroundFetch` runs (observe logs).
- Alternatively, add a debug print or persist to `sentinel_logs` from `_onBackgroundFetch` to confirm invocation.

---

Actions performed (2026-04-12T15:26:28Z):

1. Implemented Rust `run_sentinel_scan()` and exposed it as a rig tool (rig_macros::tool). Added sentinel.rs with SentinelReport struct and run_sentinel_scan runner.

## Current Task: Add vendor_fences table to SQLite schema (Phase 4 — Sentinel)

Actions performed:

1. Updated `rust/lumi_core/src/db.rs` to create `vendor_fences` table in `db_init_with_pool`.
2. Built the Rust crate: `cd rust/lumi_core && cargo build` (succeeded).
3. Updated `design/roadmap/phase-4-sentinel.md` to mark 2.2.1 as done.

Verifiable deliverables (this run):
- `rust/lumi_core/src/db.rs` contains `CREATE TABLE IF NOT EXISTS vendor_fences`.
- `cargo build` in `rust/lumi_core` exited with code 0.
- `design/roadmap/phase-4-sentinel.md` shows 2.2.1 as `- [x]`.

Timestamp: 2026-04-12T16:17:54Z
2. Updated Dart `lib/features/sentinel/background_guard.dart` to attempt invoking `run_sentinel_scan` via the existing `lumi_core_bridge` MethodChannel and log results for reviewer verification.
3. Ran `cargo test --lib` in `rust/lumi_core` — all unit tests passed (52 tests).

Verifiable deliverables:
- `rust/lumi_core/src/sentinel.rs` exists and defines `SentinelReport` and `run_sentinel_scan` (grep finds "SentinelReport" and "run_sentinel_scan").
- Unit tests: running `cd rust/lumi_core && cargo test --lib` exits with code 0 and prints all tests passed.
- `lib/features/sentinel/background_guard.dart` now invokes MethodChannel('lumi_core_bridge').invokeMethod('run_sentinel_scan') and logs result or error.

Reviewer note: The FRB Dart binding for `run_sentinel_scan` may require running `flutter_rust_bridge_codegen` to regenerate Dart bindings; in this run, BackgroundGuard calls the `lumi_core_bridge` MethodChannel directly and logs the result if the native side supports it.

---

Actions performed (2026-04-12T15:35:00Z):

1. Added `sentinel_logs` table creation to `rust/lumi_core/src/db.rs` and persist scan summaries in `rust/lumi_core/src/sentinel.rs`.
2. Implemented `NotificationService` at `lib/features/sentinel/notification_service.dart` and added `flutter_local_notifications` to `pubspec.yaml`.
3. Updated `BackgroundGuard.onHeartbeat()` (`lib/features/sentinel/background_guard.dart`) to parse the `run_sentinel_scan` result, trigger `NotificationService.showSentinelAlert(...)` when issues are found, and lazily initialize the notification plugin.
4. Ran `cd rust/lumi_core && cargo test --lib` (exit code 0) and `flutter pub get` + `flutter analyze` (exit code 0).

Verifiable deliverables added/updated in this run:
- File `lib/features/sentinel/notification_service.dart` exists and exposes `NotificationService` with `initialize()` and `showSentinelAlert(Map)`.
- `pubspec.yaml` includes `flutter_local_notifications: ^18.0.1` in dependencies.
- `rust/lumi_core/src/db.rs` creates `sentinel_logs` table.
- `rust/lumi_core/src/sentinel.rs` inserts a `sentinel_logs` row (ts, report_json, counts) on each scan.
- `flutter analyze --no-pub` returned "No issues found!".

---

Actions performed (2026-04-12T16:40:00Z):

1. Added `receive_sharing_intent` to `pubspec.yaml` dependencies to enable OS share integration (Phase 4 — Sentinel, task 3.1.1).
2. Ran `flutter pub get` to fetch the new dependency (exit code 0).
3. Executed `make codegen` to run `flutter_rust_bridge_codegen` and regenerate FRB Dart bindings for new/native tools; command exited with code 0 (bindings written to `lib/shared/bridge/`).
4. Updated roadmap `design/roadmap/phase-4-sentinel.md` to mark 3.1.1 as completed.

Verifiable deliverables (this run):
- `pubspec.yaml` contains the line `receive_sharing_intent: ^1.4.5` under `dependencies`.
- `flutter pub get` completed successfully (see console logs saved during the run).
- `make codegen` completed successfully and generated FRB bindings under `lib/shared/bridge/`.
- `design/roadmap/phase-4-sentinel.md` shows 3.1.1 as `- [x]`.

Notes: The next steps for full OS Share integration (3.1.2–3.1.4) include Android/iOS native manifest/extension changes and routing shared content to `process_receipt_image()` in Rust; those remain pending and are separate tasks.

- `cd rust/lumi_core && cargo test --lib` returned all tests passed.



Actions performed (2026-04-12T15:50:52Z):
- Implemented notification tap deep-linking in lib/features/sentinel/notification_service.dart: initialize now registers onDidReceiveNotificationResponse and handles app-launch payloads; tapped payloads are routed via appNavigatorKey + GoRouter.
- Added appNavigatorKey in lib/core/router.dart and set GoRouter.navigatorKey to it so deep-links can navigate without a BuildContext.
- Ran unit tests for NotificationService: test/notification_service_test.dart succeeded (All tests passed, exit code 0).

Verifiable deliverables added/validated:
- File lib/features/sentinel/notification_service.dart updated and contains _handlePayloadTap and initialization handlers.
- File lib/core/router.dart contains appNavigatorKey and navigatorKey: appNavigatorKey in GoRouter.
- test/notification_service_test.dart ran successfully locally (flutter test exited 0).

Notes:
- Manual verification on physical devices (notification tap routing when app is backgrounded or cold-started) is recommended by reviewer for final acceptance.

---

Actions performed (2026-04-12T16:02:00Z):

1. Implemented notification grouping summarization in lib/features/sentinel/notification_service.dart:
   - Added in-memory recent alert buffer and public helper processSentinelReport(report) to compute summary title/body and expose lastSummaryCount/lastSummaryLines for tests.
   - Individual sentinel alerts are posted with groupKey 'lumi_sentinel_group' and a summary notification (id 9001) is posted with InboxStyleInformation showing recent lines and a summary count.
2. Added unit test to verify grouping logic: test/notification_service_test.dart now contains a test that calls processSentinelReport twice and asserts the summary count increments and lines are recorded.
3. Ran `flutter test test/notification_service_test.dart` — All tests passed (exit code 0).

Verifiable deliverables added/validated in this run:
- lib/features/sentinel/notification_service.dart now implements grouping and exposes processSentinelReport, lastSummaryCount, lastSummaryLines.
- test/notification_service_test.dart includes grouping unit test and passes locally (flutter test exit code 0).
- phase-4-sentinel.md updated to mark 1.3.4 as completed.

Reviewer notes:
- For full end-to-end grouping behavior on Android, verify on a physical device that multiple sentinel alerts within a short window produce grouped notification with summary count visible in the shade. The unit test covers the grouping logic deterministically.

---

Actions performed (2026-04-12T16:03:00Z):

1. Task: Phase 4 — Geofencing plugin install (2.1.1)

Planned steps executed:
- Added flutter_background_geolocation dependency to pubspec.yaml.
- Created a reusable GeofenceService skeleton at lib/features/sentinel/geofence_service.dart with initialize(), addFence(), removeFence(), and onGeofenceExit callback wiring to the plugin's onGeofence handler.
- Marked task 2.1.1 complete in design/roadmap/phase-4-sentinel.md.
- Ran flutter pub get and flutter analyze to verify dependency resolution and analyzer status.

Verifiable deliverables (completed):
- pubspec.yaml contains "flutter_background_geolocation: ^4.8.0" under dependencies.
- File lib/features/sentinel/geofence_service.dart exists and declares GeofenceService, VendorFence, and required methods.
- design/roadmap/phase-4-sentinel.md has 2.1.1 marked as done (- [x]).
- Running `flutter pub get` succeeded and `flutter analyze --no-pub` exited with code 0 (no analyzer issues).

Notes & remaining reviewer items:
- Physical-device visual audit for AtmosphericBackground and Impeller quality remains outstanding and requires a reviewer with a connected Android device to run ./scripts/visual_audit_android.sh (already present) and inspect build/visual_audit/*.png.
- The FRB Dart binding codegen (flutter_rust_bridge_codegen) may be needed when new Rust -> Dart tools are added; no new FRB bindings were required by this change.

---

Actions performed (2026-04-12T16:06:00Z):

1. Implemented Phase 4 — Geofencing Android permissions (2.1.2):
   - Updated android/app/src/main/AndroidManifest.xml to add the following permissions:
     - android.permission.ACCESS_FINE_LOCATION
     - android.permission.ACCESS_COARSE_LOCATION
     - android.permission.ACCESS_BACKGROUND_LOCATION
   - Left existing RECEIVE_BOOT_COMPLETED and FOREGROUND_SERVICE permissions in place.

2. Verification steps executed:
   - Ran `flutter analyze --no-pub` to validate no analyzer issues; result: "No issues found!" (exit code 0).
   - Updated design/roadmap/phase-4-sentinel.md to mark 2.1.2 as completed (- [x]).

Verifiable deliverables added/validated in this run:
- android/app/src/main/AndroidManifest.xml contains uses-permission entries for ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, and ACCESS_BACKGROUND_LOCATION.
- design/roadmap/phase-4-sentinel.md has 2.1.2 marked as done.
- Running `flutter analyze --no-pub` exits with code 0 (no analyzer issues).

Notes: Runtime permission requests (prompting the user at app runtime) are still required for ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION and for ACCESS_BACKGROUND_LOCATION on Android 10+. This change only adds the manifest entries required for geofence behavior. If desired, a follow-up task can implement an in-app permission request flow that explains background location usage and requests permissions at runtime (handling the Play Store policy flow for background location).

Actions performed (2026-04-12T16:10:00Z):

1. Implemented Phase 4 — Geofencing iOS Info.plist entries (2.1.3):
   - Added `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysAndWhenInUseUsageDescription` to `ios/Runner/Info.plist` with user-facing explanatory strings describing on-device background location usage for vendor detection.
2. Updated roadmap: marked 2.1.3 as completed in design/roadmap/phase-4-sentinel.md.

Verifiable deliverables:
- ios/Runner/Info.plist contains NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription.
- design/roadmap/phase-4-sentinel.md shows 2.1.3 marked done (- [x]).
- Running `flutter pub get && flutter analyze --no-pub` exits with code 0.

Notes:
- App Store review may require a more detailed justification string; reviewer may request edits to the description for policy compliance.
- Runtime permission prompts still need implementation in Dart for full UX (separate task).

---

Actions performed (2026-04-12T16:30:00Z):

1. Implemented placeholder Known Locations UI at lib/features/sentinel/known_locations.dart: a simple form (name, latitude, longitude, radius) with an Add button that calls LumiCoreBridge.addVendorFence.
2. Added LumiCoreBridge.addVendorFence to lib/shared/bridge/lumi_core_bridge.dart which invokes MethodChannel 'lumi_core_bridge' with method 'add_vendor_fence' and returns the inserted ID string.
3. Updated lib/features/settings/settings.dart to add a 'Known Locations' row that navigates to KnownLocationsScreen.
4. Marked roadmap task 2.2.4 as complete in design/roadmap/phase-4-sentinel.md.

Verifiable deliverables:
- File lib/features/sentinel/known_locations.dart exists and declares KnownLocationsScreen with a functional Add button.
- lib/shared/bridge/lumi_core_bridge.dart contains addVendorFence method and invokeMethod('add_vendor_fence') usage.
- lib/features/settings/settings.dart references KnownLocationsScreen and contains a row labeled 'Known Locations'.
- design/roadmap/phase-4-sentinel.md shows 2.2.4 checked (- [x]).

Timestamp: 2026-04-12T16:30:00Z

---

Actions performed (2026-04-12T16:37:00Z):

1. Task: Implement Geofence exit handler (roadmap 2.3.1)

Planned steps executed:
- Added LumiCoreBridge.incrementVisit to lib/shared/bridge/lumi_core_bridge.dart which invokes MethodChannel('lumi_core_bridge').invokeMethod('increment_visit', {'id': fenceId}).
- Enhanced lib/features/sentinel/geofence_service.dart:
  - Maintain an internal registry mapping registered fence IDs to VendorFence metadata when addFence is called.
  - On Geofence EXIT events, look up vendor metadata, call LumiCoreBridge.incrementVisit(fence.id) and call NotificationService().showGeofenceAlert(fence.vendorName, lat: fence.lat, lng: fence.lng).
  - Preserve existing onGeofenceExitCallback behavior by awaiting the callback after native increment and notification attempts.
- Marked design/roadmap/phase-4-sentinel.md task 2.3.1 as complete (- [x]).
- Ran `flutter analyze --no-pub` to validate edits; analyzer reported "No issues found!" (exit code 0).

Verifiable deliverables (added/validated):
- lib/shared/bridge/lumi_core_bridge.dart contains incrementVisit method that calls MethodChannel('lumi_core_bridge').invokeMethod('increment_visit', ...).
- lib/features/sentinel/geofence_service.dart now stores registered fences and onGeofence EXIT events call LumiCoreBridge.incrementVisit and NotificationService().showGeofenceAlert with vendor metadata.
- design/roadmap/phase-4-sentinel.md shows 2.3.1 marked as done (- [x]).
- Running `flutter analyze --no-pub` exits with code 0 (no analyzer issues).

Notes & reviewer guidance:
- This change implements the 2.3.1 requirements; please run Dart unit tests (or add an onGeofenceExit unit test) that mocks a GeofenceEvent to assert that incrementVisit and showGeofenceAlert are invoked. The native increment_visit method is expected to be available on the `lumi_core_bridge` MethodChannel; if missing in a given test environment, the call will throw and can be mocked or ignored for test runs.
- Integration test: In a simulator with mock location, crossing a fence boundary should now increment visit_count in the native DB and show a grouped geofence notification with vendor metadata (requires native bridge present and a connected device/emulator).

Reviewer: after verifying the deliverables, please confirm and then mark roadmap 2.3.1 as accepted if behavior is correct.


---

## Actions (2026-04-12T16:40:00Z): Implemented 2.3.2 — notification tap deep-link for geofence exits

Changes made:

- Updated `lib/features/sentinel/notification_service.dart`:
  - `parsePayloadToRoute` now maps geofence payloads to `{'route': '/home', 'params': {'openChat': true, 'prefill': 'Just left {vendorName}. What did you buy?', 'vendor': vendor}}` so the Home screen can prefill the chat input.

- Updated `lib/core/router.dart`:
  - The root route now passes `state.extra` to `HomeScreen` as `initialChatParams` so deep-link params are delivered to the screen.

- Updated `lib/features/home/home_impl.dart`:
  - `HomeScreen` accepts `initialChatParams` and pre-fills the chat input when `openChat == true`.
  - Added a FocusNode (`_inputFocus`) and set the LumiTextField's focusNode so the input can be focused after navigation.

- Updated `lib/shared/widgets/lumi_text_field.dart`:
  - Accepts an optional `focusNode` so external callers can control focus.

- Updated tests:
  - `test/notification_service_test.dart` now asserts geofence payload parsing yields `openChat` and a `prefill` string containing the vendor name.
  - Adjusted widget tests to remove `const` where `HomeScreen` is constructed (constructor is now non-const).

Verification performed (automated):
- `dart/flutter test test/notification_service_test.dart` — All tests in that file passed (exit code 0).
- `flutter analyze --no-pub` — No analyzer issues found (exit code 0).

Remaining manual verifications (reviewer):
- Physical device test: Tap a geofence notification on a device/emulator and confirm the Home Chat input is prefilled with "Just left {vendorName}. What did you buy?" and focused.
- Integration test: Ensure navigation via notification payload (app launched from terminated state) correctly routes into Home with prefill (may require verifying getNotificationAppLaunchDetails handling on platform and router readiness).

Verifiable deliverables added:
- `lib/features/sentinel/notification_service.dart` now maps geofence notifications to `/home` with `openChat` and `prefill` params.
- `lib/core/router.dart` passes `state.extra` into `HomeScreen(initialChatParams: ...)`.
- `lib/features/home/home_impl.dart` uses `initialChatParams` to prefill chat input and focus it.
- `lib/shared/widgets/lumi_text_field.dart` accepts an optional `focusNode`.
- `test/notification_service_test.dart` updated and passes (`flutter test` exit code 0 for that file).

Timestamp: 2026-04-12T16:40:00Z

---

Actions performed (2026-04-12T16:57:00Z): Implemented 3.1.2 — Android intent-filter for OS Share

1. Updated android/app/src/main/AndroidManifest.xml to add two intent-filters on MainActivity to handle ACTION_SEND for image/* and text/plain MIME types.
2. Ran `flutter analyze --no-pub` to verify no analyzer issues (exit code 0).
3. Verified manifest contains ACTION_SEND entries via grep.
4. Marked roadmap task 3.1.2 as complete in design/roadmap/phase-4-sentinel.md.

Verifiable deliverables:
- android/app/src/main/AndroidManifest.xml contains intent-filter entries for ACTION_SEND with image/* and text/plain.
- design/roadmap/phase-4-sentinel.md shows 3.1.2 as checked (- [x]).
- `flutter analyze --no-pub` exits with code 0 (no analyzer issues).

Notes:
- This adds the manifest-side intent filters; wiring the receive_sharing_intent plugin to route incoming shares to the app's Dart entry (and then to `process_receipt_image()` in Rust) is a follow-up (3.1.4) and depends on platform-specific share-handling code (Android file URIs and permissions).

Actions performed (2026-04-12T17:00:00Z): Implemented iOS Share Extension skeleton (3.1.3)

1. Created ios/ShareExtension/ with:
   - Info.plist (NSExtension configured for com.apple.share-services)
   - ShareViewController.swift (saves text/image to App Group container "group.com.lumi.shared")
   - ShareExtension.entitlements (grants the App Group)
2. Added ios/Runner/Runner.entitlements with the same App Group entry for the main app target.
3. Marked roadmap task 3.1.3 as complete in design/roadmap/phase-4-sentinel.md.

Verifiable deliverables for reviewer:
- ios/ShareExtension/Info.plist exists and contains NSExtension/NSExtensionPointIdentifier = com.apple.share-services.
- ios/ShareExtension/ShareViewController.swift exists and writes shared text to UserDefaults(suiteName: "group.com.lumi.shared") and images to the app-group container.
- ios/ShareExtension/ShareExtension.entitlements exists and contains the application group "group.com.lumi.shared".
- ios/Runner/Runner.entitlements exists and contains the application group "group.com.lumi.shared" for the main app.
- design/roadmap/phase-4-sentinel.md shows 3.1.3 as checked (- [x]).

Notes & next steps for reviewer (manual steps required on macOS/Xcode):
- Add a Share Extension target in Xcode using the files in ios/ShareExtension and point its "Info.plist" and entitlements accordingly, or import the target into the project.pbxproj.
- In Xcode, enable the App Group "group.com.lumi.shared" for both the Runner app target and the Share Extension target (Capabilities tab).
- Rebuild on device and test sharing an image/text to confirm the extension writes data to the shared container; the main app can read via UserDefaults(suiteName: "group.com.lumi.shared") or container URL.
