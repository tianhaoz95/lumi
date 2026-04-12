# Phase 5: Aurora — UX Polish & Audit

> **Goal:** Deliver the full "Cozy Cabin" visual experience — complete design system application, Kit the Fox animations, haptic feedback profiles, dark mode, SHA-256 audit trail export, and a PDF "Tax Evidence Report." The UI must sustain 120 fps on the Impeller renderer; the audit report must contain verifiable hashes.

**Prerequisite:** Phase 4 acceptance criteria fully met.

---

## 1. Design System — Full Application

### 1.1 Global Theme Completion

- [x] **1.1.1** Audit every screen against the approved HTML mockups in `design/ui_design/`. File a task for each deviation (use the `design_debt` SQLite table below).
- [x] **1.1.2** Create `design_debt` SQLite table (dev-only, not shipped):
  ```sql
  CREATE TABLE design_debt (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    screen TEXT,
    description TEXT,
    status TEXT DEFAULT 'open'
  );
  ```
- [x] **1.1.3** Apply the **No-Line Rule** globally: find all `Divider()`, `Container(border: Border(...))`, and explicit `1px` borders and replace with tonal shifts or negative space.
- [x] **1.1.4** Apply the **No-Sharp-Corner Rule**: audit all `BorderRadius` values and ensure minimum `Radius.circular(16)`.
- [x] **1.1.5** Apply the **No-Pure-Black Rule**: find all `Colors.black` and replace with `LumiColors.onSurface` (`#171C1E`).

**Tests:**
- Golden tests for all 6 screens: render with the Glacial Sanctuary theme and diff against approved PNGs in `design/ui_design/*/screen.png`.
- Widget test: no `Divider` widget appears in any production screen tree.

### 1.2 Glassmorphism Completeness

- [x] **1.2.1** Confirm `TopAppBar` on all screens uses `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` with `surface-container-lowest` at 70% opacity.
- [x] **1.2.2** Confirm `FloatingNavBar` is a pill shape, does not span full width, and uses glassmorphism.
- [x] **1.2.3** Confirm all modals and bottom sheets use the glassmorphism card template.

### 1.3 Grain Texture & Atmospheric Orbs

- [x] **1.3.1** Implement the grain texture as an SVG-based background at 2–3% opacity, fixed in position.  <!-- Implemented: reintroduced feTurbulence filter; test-time fallback retained -->
- [x] **1.3.2** Ensure `AtmosphericBackground` orbs are in place on Login, Sign Up, Forgot Password, Home, and Dashboard screens.
- [x] **1.3.3** Verify grain texture does not impact frame rate (use Flutter DevTools performance overlay).

---

## 2. Animation System

### 2.1 Global Animation Constants

- [x] **2.1.1** Create `LumiAnimations` constants class:
  ```dart
  static const driftDuration = Duration(milliseconds: 400);
  static const driftCurve = Curves.easeOut;
  static const snapDuration = Duration(milliseconds: 150);
  static const snapCurve = Curves.easeInOut;
  ```
- [x] **2.1.2** Replace all `AnimatedContainer`, `AnimationController`, and `TweenAnimationBuilder` usages to reference `LumiAnimations` constants (no hardcoded durations).
- [x] **2.1.3** Verify: no animation duration < 300 ms (except micro-snaps ≤ 150 ms) and none > 500 ms.

### 2.2 Kit the Fox — Animations

- [x] **2.2.1** Create 4 Kit animation states using Lottie or a Flutter custom painter:
  - **Idle** — gentle breathing (scale 1.0 → 1.03 → 1.0, 2 s loop).
  - **Thinking** — Kit "digging through a snowbank" (lateral swipe with particle dots, 1.5 s loop). Plays while Rig agent is processing.
  - **Found** — Kit emerges from snowbank holding a data card (plays once on tool result return, 0.8 s).
  - **Alert** — Kit's ears perk up (plays once on Sentinel notification, 0.4 s).
- [ ] **2.2.2** Replace the static `KitGhost` widget in `HomeScreen` with the animated Kit widget. Show **Thinking** animation while `agent_chat` stream is active.
- [ ] **2.2.3** Show **Found** animation when a tool result (InsightCard) is rendered.
- [ ] **2.2.4** Ghost Kit (5–10% opacity) overlaid in the background of `DashboardScreen` using the **Idle** animation.

**Tests:**
- Widget test: `KitAnimated` transitions from `Idle` to `Thinking` when `isProcessing == true`.
- Widget test: `KitAnimated` plays `Found` animation exactly once when `onToolResult` fires.
- Performance test: Kit animation sustains 60+ fps on profile build (Flutter DevTools frame chart).

### 2.3 Screen Transitions

- [ ] **2.3.1** Implement a custom `PageRouteBuilder` using a fade + vertical drift (translate Y +20 → 0) with `driftDuration`.
- [ ] **2.3.2** Apply to all `go_router` routes.
- [ ] **2.3.3** Tab switches within the bottom nav bar use a cross-fade only (no translate).

**Tests:**
- Widget test: navigating from Login → Home triggers the fade+drift transition.

### 2.4 Micro-Interactions

- [ ] **2.4.1** `LumiButton`: scale 1.02× on hover (Flutter `MouseRegion`), 0.98× on tap press, spring back with `Curves.elasticOut`.
- [ ] **2.4.2** `TransactionCard`: hover increases `boxShadow` blur from 0 to 6px over `driftDuration`.
- [ ] **2.4.3** Chat send button: scale 1.08× on press, then send animation (shrink → expand to fill → fade out loading ring).
- [ ] **2.4.4** Bottom nav item: selected icon animates with a "fill" toggle (Material Symbols FILL 0 → 1 over 200 ms).

---

## 3. Haptic Feedback

### 3.1 Haptic Profiles

- [ ] **3.1.1** Add `haptic_feedback` (built-in Flutter) calls for each profile:
  - **"Crunchy Snow"** (`HapticFeedback.mediumImpact()`) — on transaction confirm, tab switch.
  - **"Ice Click"** (`HapticFeedback.lightImpact()`) — on any button tap, field focus.
  - **"Permafrost Lock"** (`HapticFeedback.heavyImpact()`) — on audit trail generation, account deletion confirmation.
- [ ] **3.1.2** Create `LumiHaptics` utility class wrapping all three profiles.
- [ ] **3.1.3** Wire haptic calls throughout the app (audit each interactive widget).

**Tests:**
- Widget test: `TransactionCard` Confirm button calls `LumiHaptics.crunchySnow()`.
- Widget test: Audit export button calls `LumiHaptics.permafrostLock()`.

---

## 4. Dark Mode

### 4.1 Dark Palette

- [ ] **4.1.1** Define `darkTheme` in `lib/core/theme.dart` with dark variants of all color tokens:
  - `surface: Color(0xFF0E1315)` (deep "Permafrost Night")
  - `primary: Color(0xFF8AD3D7)`
  - `onSurface: Color(0xFFE2E7E9)`
  - Full dark token set consistent with Material You dynamic color spec.
- [ ] **4.1.2** `MaterialApp` uses `themeMode: ThemeMode.system` by default.
- [ ] **4.1.3** Add a theme toggle in Settings → Account Preferences (Light / Dark / System).

**Tests:**
- Widget test: all 6 screens render without overflow or contrast issues in dark mode (golden tests).
- Widget test: Settings theme toggle persists across app restarts (using shared preferences).

---

## 5. SHA-256 Audit Trail

### 5.1 Audit Chain Design

- [ ] **5.1.1** Each `transactions` row already stores a `sha256_hash` from Phase 3. In this phase, implement a **chain hash**:
  - `chain_hash = SHA-256(prev_chain_hash + current_tx_hash)`
  - Store `chain_hash` in a new `chain_hash` column on the `transactions` table (migration).
  - The first transaction's `prev_chain_hash` is `SHA-256("lumi-genesis")`.
- [ ] **5.1.2** Implement `verify_audit_chain() -> Result<AuditVerificationResult>` in Rust:
  - Iterates all transactions in insertion order.
  - Recomputes each chain hash from scratch.
  - Returns `{ is_valid: bool, first_tampered_id: Option<u64> }`.
- [ ] **5.1.3** Expose via FRB. Surface in Settings → Security as a "Verify Integrity" button.

**Tests:**
- Rust unit test: inserting 5 transactions and calling `verify_audit_chain()` returns `is_valid == true`.
- Rust unit test: manually mutating one transaction's `amount` in the DB and calling `verify_audit_chain()` returns `is_valid == false` and the correct `first_tampered_id`.
- Rust unit test: chain is correctly re-anchored at the genesis hash for the first transaction.

### 5.2 Settings — Security Screen

- [ ] **5.2.1** Create `SecurityScreen` (placeholder from Phase 1):
  - "Verify Data Integrity" button → calls `verify_audit_chain()` → shows result card (green "Chain intact" or red "Tampering detected at entry #{id}").
  - "Export Audit Log" button → triggers PDF export (§6).

---

## 6. PDF Tax Evidence Report

### 6.1 Report Generation (Rust)

- [ ] **6.1.1** Add `printpdf` crate to `rust/Cargo.toml`.
- [ ] **6.1.2** Implement `generate_tax_report(year: u32) -> Result<Vec<u8>>` in Rust:
  - **Cover page**: Lumi logo mark, user name, tax year, generation timestamp, chain hash of the entire database at export time.
  - **Summary page**: Total expenses by category (table), total mileage and IRS deduction, net deductible amount.
  - **Transaction ledger**: Paginated table — date | vendor | category | amount | SHA-256 hash (first 12 chars) — one row per transaction.
  - **Verification footer** on each page: "All data is on-device. Chain hash: {hash}".
- [ ] **6.1.3** Expose via FRB as `generate_tax_report(year: u32) -> Result<Vec<u8>>`.

**Tests:**
- Rust unit test: `generate_tax_report(2026)` returns a non-empty byte vector.
- Rust unit test: parsing the returned PDF (using `pdf-extract` or a simple byte-level check) confirms it contains the user's name and the correct year.
- Rust unit test: report for an empty dataset generates a valid (though sparse) PDF.

### 6.2 Flutter — Export Flow

- [ ] **6.2.1** In Settings → Security screen, "Export Tax Report" button:
  1. Shows year picker dialog (default: current year).
  2. Calls `generate_tax_report(year)` via FRB with a loading overlay.
  3. Saves the returned bytes to the platform's Documents directory.
  4. Opens the file with `open_file` package.
- [ ] **6.2.2** Show a `LumiCard` confirmation: "Your 2026 Tax Evidence Report is ready. {file_path}"

**Tests:**
- Widget test: year picker defaults to current year.
- Widget test: loading overlay shows while `generate_tax_report` future is pending.
- Widget test: on success, confirmation card appears with a non-empty file path.
- Widget test: on failure, error snackbar shows without crashing.

---

## 7. Performance Validation — 120 fps

### 7.1 Impeller Renderer Checks

- [ ] **7.1.1** Ensure `--enable-impeller` flag is set for all release builds (Flutter 3.x default on iOS; confirm on Android).
- [ ] **7.1.2** Run Flutter DevTools "Performance" view on a physical device. Record frame render times for:
  - Dashboard scroll (60 frames).
  - Home chat stream (during token output).
  - Screen transition (Login → Home).
- [ ] **7.1.3** Assert: no frame exceeds 8.33 ms render time (120 fps budget) for the above sequences.
- [ ] **7.1.4** Fix any identified jank sources (common causes: `BackdropFilter` on the main thread, large decoded images, unresolved shader compilation).

**Tests:**
- Performance integration test (`flutter drive` with `--profile`): dashboard scroll average frame time < 8 ms.
- Performance integration test: Kit the Fox Idle animation average frame time < 8 ms.

---

## 8. "Local Shield" Privacy Indicator

- [ ] **8.1** Add a persistent `LocalShieldBadge` widget to the `TopAppBar` on Home and Dashboard screens:
  - Material Symbol `shield` icon in `primary` color with a subtle pulsing glow animation (opacity 0.6 → 1.0 → 0.6, 3 s loop).
  - Tapping it shows a tooltip/bottom sheet: "All your financial intelligence stays on this device. Nothing is uploaded."
- [ ] **8.2** The badge changes to a warning state (amber color) if any network call is detected from the financial data layer (assertion in debug mode).

**Tests:**
- Widget test: `LocalShieldBadge` renders on Home and Dashboard screens.
- Widget test: tapping badge opens the privacy explanation sheet.

---

## Phase 5 — Acceptance Criteria

| # | Criterion | How to Verify |
|---|---|---|
| P5-1 | All 6 screens match approved PNGs within golden test tolerance | `flutter test --update-goldens` then diff |
| P5-2 | No divider lines, no sharp corners, no pure black in production screens | Widget tree audit tests |
| P5-3 | 120 fps sustained on scroll and Kit animation | DevTools performance integration test |
| P5-4 | All 4 Kit animations play correctly on trigger | Widget tests |
| P5-5 | Dark mode renders correctly on all screens | Golden tests in dark mode |
| P5-6 | `verify_audit_chain()` correctly detects tampering | Rust unit tests |
| P5-7 | PDF report is generated with SHA-256 hashes and can be opened | Widget + Rust integration tests |
| P5-8 | `LocalShieldBadge` visible and interactive | Widget tests |
| P5-9 | Haptic profiles fire on correct interactions | Widget tests via `LumiHaptics` mock |
| P5-10 | Theme toggle persists across restarts | Widget test |
