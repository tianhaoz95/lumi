# Phase 4: Sentinel — Proactive Layer

> **Goal:** Implement Lumi's proactive intelligence: a background heartbeat that wakes the E2B model hourly to scan for gaps in the books, geofence triggers that detect when the user leaves a known vendor and prompt them to log an entry, and soft push notifications for all alerts. Battery impact must stay < 4% per day; geofence notifications must fire within 60 s of leaving a venue.

**Prerequisite:** Phase 3 acceptance criteria fully met.

---

## 1. BackgroundGuard Heartbeat

### 1.1 Platform Background Execution Setup

- [x] **1.1.1** Add `flutter_background_fetch` (or `workmanager`) to `pubspec.yaml` for cross-platform background task scheduling.
- [x] **1.1.2** Configure Android:
  - Register `BackgroundFetchHeadlessTask` in `AndroidManifest.xml`.
  - Request `RECEIVE_BOOT_COMPLETED` and `FOREGROUND_SERVICE` permissions.
  - Set minimum interval to 60 minutes (`BackgroundFetch.MINIMUM_FETCH_INTERVAL_15MIN` × 4).
- [x] **1.1.3** Configure iOS:
  - Enable **Background Fetch** and **Background Processing** capabilities in Xcode.
  - Register BGAppRefreshTask identifier `com.lumi.app.heartbeat`.
  - Schedule BGProcessingTask for longer Sentinel scans when device is charging.
- [x] **1.1.4** Create `BackgroundGuard` class in `lib/features/sentinel/background_guard.dart`:
  - `initialize()` — registers the background task on app start.
  - `onHeartbeat()` — called by the platform when the task fires.

**Verifiable result:** In a simulator/emulator, force-trigger the background task and confirm `onHeartbeat()` is called.

### 1.2 Sentinel Scan Logic (Rust)

- [ ] **1.2.1** Implement `run_sentinel_scan() -> Result<SentinelReport>` in Rust, exposed via FRB:
  - Query SQLite for transactions in the past 7 days where `is_tagged == false`.
  - Query for any day in the past 14 days with zero transaction entries.
  - Query for mileage logs without a `purpose` field.
  - Return a `SentinelReport` with lists of issues.
- [ ] **1.2.2** `SentinelReport` structure:
  ```rust
  pub struct SentinelReport {
      pub untagged_count: u32,
      pub missing_days: Vec<String>,   // ISO 8601 dates
      pub incomplete_mileage: Vec<u64>, // mileage_log IDs
  }
  ```
- [ ] **1.2.3** `BackgroundGuard.onHeartbeat()` in Dart:
  1. Call `run_sentinel_scan()` via FRB.
  2. If report is non-empty, trigger a local notification (§1.3).
  3. Log the scan result and timestamp to `sentinel_logs` SQLite table.

**Tests:**
- Rust unit test: `run_sentinel_scan()` with 3 untagged transactions returns `untagged_count == 3`.
- Rust unit test: seeded dataset with a gap on Monday returns that date in `missing_days`.
- Rust unit test: empty database returns all-zero `SentinelReport`.
- Dart unit test: `BackgroundGuard.onHeartbeat()` calls `showNotification` when `untagged_count > 0`.
- Dart unit test: `BackgroundGuard.onHeartbeat()` does NOT call `showNotification` when report is empty.

### 1.3 Local Notifications

- [ ] **1.3.1** Add `flutter_local_notifications` to `pubspec.yaml`.
- [ ] **1.3.2** Create `NotificationService` in `lib/features/sentinel/notification_service.dart`:
  - `initialize()` — request permission, configure notification channels.
  - `showSentinelAlert(SentinelReport report)` — dispatches appropriate notification copy:
    - Untagged: *"You have 3 untagged transactions. Tap to review with Lumi."*
    - Missing day: *"No entries logged for Monday. Tap to review."*
    - Geofence (§2): *"Just finished at {vendor}? Tap to snap your receipt."*
- [ ] **1.3.3** Tapping the notification deep-links to the relevant screen (untagged → Dashboard, geofence → Camera/Chat).
- [ ] **1.3.4** Implement notification grouping: if multiple alerts fire, bundle them into one notification with a summary count.

**Tests:**
- Dart unit test: `showSentinelAlert` with `untagged_count == 5` generates copy containing "5".
- Dart unit test: notification payload deep-link for untagged resolves to `/dashboard` route.
- Dart unit test: notification payload deep-link for geofence resolves to `/home` route with `openCamera: true`.
- Integration test: notification permission request shows the system dialog (manual verification gate).

---

## 2. Geofencing

### 2.1 Plugin Setup

- [ ] **2.1.1** Add `flutter_background_geolocation` to `pubspec.yaml`.
- [ ] **2.1.2** Configure Android permissions: `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `ACCESS_COARSE_LOCATION`.
- [ ] **2.1.3** Configure iOS: add `NSLocationAlwaysAndWhenInUseUsageDescription` and `NSLocationWhenInUseUsageDescription` to `Info.plist`.
- [ ] **2.1.4** Create `GeofenceService` in `lib/features/sentinel/geofence_service.dart`:
  - `initialize()` — configure the plugin (distanceFilter, desiredAccuracy, etc.).
  - `addFence(VendorFence fence)` — register a circular geofence.
  - `removeFence(String vendorId)` — deregister a geofence.
  - `onGeofenceExit(VendorFence fence)` callback.

**Verifiable result:** In a simulator with mock location, crossing a fence boundary calls `onGeofenceExit` within 60 s.

### 2.2 Vendor Fence Registry

- [ ] **2.2.1** Add a `vendor_fences` table to SQLite schema (migration):
  ```sql
  CREATE TABLE vendor_fences (
    id TEXT PRIMARY KEY,
    vendor_name TEXT NOT NULL,
    lat REAL NOT NULL,
    lng REAL NOT NULL,
    radius_meters REAL NOT NULL DEFAULT 150.0,
    visit_count INTEGER DEFAULT 0,
    last_visited TEXT
  );
  ```
- [ ] **2.2.2** Implement `VendorFenceService` in Rust (exposed via FRB):
  - `add_vendor_fence(name, lat, lng) -> Result<String>` — inserts and returns ID.
  - `get_all_fences() -> Result<Vec<VendorFence>>` — returns all registered fences.
  - `increment_visit(fence_id: String)` — updates `visit_count` and `last_visited`.
- [ ] **2.2.3** On app start, call `get_all_fences()` and register all with `GeofenceService`.
- [ ] **2.2.4** Allow users to add fences manually from Settings → "Known Locations" (placeholder UI in Phase 4; full UI in Phase 5).

**Tests:**
- Rust unit test: `add_vendor_fence` inserts correctly and returns a non-empty ID.
- Rust unit test: `get_all_fences` returns all inserted fences.
- Dart unit test: on `GeofenceService.initialize()`, all fences from `VendorFenceService` are registered.

### 2.3 Geofence Exit Handler

- [ ] **2.3.1** In `GeofenceService.onGeofenceExit(fence)`:
  1. Call `VendorFenceService.increment_visit(fence.id)`.
  2. Call `NotificationService.showGeofenceAlert(fence.vendorName)`.
  3. The notification payload carries `vendorName` and `lat/lng` as metadata.
- [ ] **2.3.2** If the user taps the notification, open the Home Chat screen pre-loaded with the message: `"Just left {vendorName}. What did you buy?"`.

**Tests:**
- Dart unit test: `onGeofenceExit` calls `increment_visit` and `showGeofenceAlert`.
- Dart unit test: notification tap pre-populates chat input with correct prompt.
- Integration test (simulator): mock location sequence (inside → outside fence radius) fires `onGeofenceExit` within 60 s.

---

## 3. OS Share Integration

### 3.1 Share Extension Setup

- [ ] **3.1.1** Add `receive_sharing_intent` package (or native share extension implementation).
- [ ] **3.1.2** Configure Android: add intent filter for `ACTION_SEND` with `image/*` and `text/plain` MIME types in `AndroidManifest.xml`.
- [ ] **3.1.3** Configure iOS: create a Share Extension target in Xcode; use App Groups to pass the shared content to the main app.
- [ ] **3.1.4** On receiving a shared image or screenshot, route to `process_receipt_image()` in Rust (Phase 2 pipeline).

### 3.2 Subscription Detection

- [ ] **3.2.1** Implement `detect_subscription(text: String) -> Result<Option<SubscriptionInfo>>` in Rust:
  - Parse shared text for recurring charge patterns (keywords: "monthly", "annual", "subscription", "renews", "billed every").
  - If detected, return a `SubscriptionInfo` with `service_name`, `amount`, `frequency`.
- [ ] **3.2.2** If a subscription is detected, show a notification: *"Recurring charge detected from {service_name}. Tap to review and categorize."*

**Tests:**
- Rust unit test: `detect_subscription("Your Netflix subscription renews for $15.99 monthly")` returns `Some(SubscriptionInfo { service_name: "Netflix", amount: 15.99, frequency: "monthly" })`.
- Rust unit test: `detect_subscription("Thank you for your one-time purchase")` returns `None`.
- Dart unit test: subscription detected → notification copy contains service name.

---

## 4. Battery & Performance Budget

### 4.1 Battery Impact Instrumentation

- [ ] **4.1.1** Add `battery_plus` package to `pubspec.yaml`.
- [ ] **4.1.2** Create a `BatteryMonitor` in `lib/features/sentinel/battery_monitor.dart` that logs battery level before and after each `onHeartbeat()` invocation to the `sentinel_logs` table.
- [ ] **4.1.3** In the Settings screen, add a **Sentinel Health** section (dev mode only) showing:
  - Last scan timestamp.
  - Average battery impact per scan.
  - Total scans in last 24 hours.

### 4.2 Heartbeat Duration Budget

- [ ] **4.2.1** Enforce a 30-second maximum for `run_sentinel_scan()` using a Rust `tokio::time::timeout`.
- [ ] **4.2.2** If scan exceeds 30 s, cancel it and log a warning. The iOS background task must complete within its allotted time to avoid being penalized by the system scheduler.

**Tests:**
- Rust unit test: `run_sentinel_scan()` with a 31-second mock delay is cancelled and returns `Err(Timeout)`.
- Dart unit test: `BatteryMonitor` records before/after levels and computes delta correctly.

---

## Phase 4 — Acceptance Criteria

| # | Criterion | How to Verify |
|---|---|---|
| P4-1 | Background heartbeat fires every ~60 min | Manual device test over 4 hours; confirm ≥ 3 scan log entries |
| P4-2 | Sentinel notification fires for untagged transactions | Integration test: insert untagged tx → trigger heartbeat → notification shows |
| P4-3 | Geofence exit notification fires within 60 s | Simulator mock-location test |
| P4-4 | Notification deep-link routes to correct screen | Dart unit tests on payload routing |
| P4-5 | Subscription detection works on share input | Rust unit tests (all pass) |
| P4-6 | Heartbeat scan completes within 30 s under load | Rust unit test with timeout |
| P4-7 | Battery impact < 4%/day (measured baseline) | Manual 24-hour device test; `BatteryMonitor` log review |
| P4-8 | OS Share → receipt OCR pipeline works end-to-end | Integration test: share sample image → `ReceiptData` returned |
