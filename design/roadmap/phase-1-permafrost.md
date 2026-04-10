# Phase 1: Permafrost — Foundation & Bridge

> **Goal:** Establish the complete project skeleton. By the end of this phase, the Flutter app renders a working shell (all screens with mock data), auth flows are live against a local Appwrite instance, the FRB v2 Dart↔Rust bridge is proven with a round-trip latency test, and both SQLite and LanceDB are initialized in Rust.

---

## 1. Project Initialization

### 1.1 Repository & Toolchain Setup

- [x] **1.1.1** Create a Flutter 3.x project with package name `com.lumi.app`.
- [x] **1.1.2** Add a `rust/` workspace at the project root using Cargo. Create crate `lumi_core`. 
- [x] **1.1.3** Install and configure **flutter_rust_bridge v2** (FRB v2):
  - Add `flutter_rust_bridge` to `pubspec.yaml`.
  - Add `flutter_rust_bridge` and `tokio` to `rust/Cargo.toml`.
  - Run `flutter_rust_bridge_codegen generate` and verify no errors.
- [x] **1.1.4** Add a `Makefile` (or `justfile`) with top-level commands: `make setup`, `make codegen`, `make run`, `make test`. 
- [x] **1.1.5** Add `.gitignore` entries for `rust/target/`, Flutter build artifacts, and `.env`.

**Verifiable result:** `flutter run` launches without errors; `cargo build` in `rust/` succeeds.

### 1.2 Flutter Project Structure

- [x] **1.2.1** Create the folder structure:
  ```
  lib/
    core/           # App-level config, theme, router
    features/
      auth/         # Login, Sign Up, Forgot Password
      home/         # Chat screen
      dashboard/    # Tundra dashboard
      settings/     # The Cabin
    shared/
      widgets/      # Shared UI components
      bridge/       # FRB-generated Dart bindings
  ```
- [x] **1.2.2** Add dependencies to `pubspec.yaml`:
  - `go_router` — navigation
  - `appwrite` — Appwrite Flutter SDK
  - `flutter_riverpod` — state management (chosen: Riverpod)
  - `google_fonts` — Manrope + Inter
  - `material_symbols_icons` — Material Symbols icon set

**Verifiable result:** `flutter pub get` succeeds; hot reload works from `main.dart`.

---

## 2. Design System Implementation

### 2.1 Theme & Tokens

- [x] **2.1.1** Create `lib/core/theme.dart` with `ThemeData` implementing all color tokens from the design system:
  - `primary: Color(0xFF00464A)`
  - `surface: Color(0xFFF5FAFC)`
  - `onSurface: Color(0xFF171C1E)`
  - Full token list from `design/ui_design/design/DESIGN.md`
- [x] **2.1.2** Configure `TextTheme` with Manrope for display/headline styles and Inter for body/label styles with correct `letterSpacing` and `height` values.
- [x] **2.1.3** Create a `LumiColors` constant class to provide named access to all design tokens.
- [x] **2.1.4** Create a `LumiRadius` constant class: `defaultRadius = 16`, `fullRadius = 9999`.

**Verifiable result:** A `ThemeShowcase` screen (dev-only route) renders all token colors and text styles correctly against the DESIGN.md reference.

### 2.2 Shared Widgets

- [x] **2.2.1** `LumiCard` — glassmorphism card (`BackdropFilter`, `BoxDecoration` with `surface-container-lowest` at 70% opacity, `boxShadow` at 4–6% opacity).
- [x] **2.2.2** `LumiButton` — primary CTA: full-pill shape, `gradient` from `primary` to `primary-container` at 135°, `InkWell` with scale animation (hover 1.02×, press 0.98×).
- [x] **2.2.3** `LumiTextField` — `surface-container-high` fill, 2px ghost-border focus ring (`primary` at 40% opacity), leading icon slot.
- [ ] **2.2.4** `KitGhost` — Kit the Fox mascot ghost widget: Material Symbol `pets` icon at configurable opacity (default 7%), `grayscale` color filter.
- [ ] **2.2.5** `AtmosphericBackground` — fixed positioned blurred orbs + grain texture overlay (SVG noise filter at 2–3% opacity).
- [ ] **2.2.6** `FloatingNavBar` — glassmorphism pill nav bar that does not span full width.

**Verifiable result:** Each widget has a corresponding widget test that renders it and matches a golden image.

---

## 3. Authentication (Appwrite)

### 3.1 Appwrite Configuration

- [ ] **3.1.1** Start Appwrite via Docker Compose and verify the console is reachable at `http://localhost/console`.
- [ ] **3.1.2** In the Appwrite console:
  - Create project `lumi-dev`.
  - Add Flutter platform with bundle ID `com.lumi.app`.
  - Enable Email/Password authentication.
  - Configure an SMTP provider (e.g., Mailhog in Docker) for password-reset emails.
- [ ] **3.1.3** Create `lib/core/env.dart` (git-ignored) with:
  ```dart
  const appwriteEndpoint = 'http://localhost/v1';
  const appwriteProjectId = 'lumi-dev';
  ```
- [ ] **3.1.4** Create `AppwriteService` singleton in `lib/features/auth/appwrite_service.dart` that initializes the Appwrite `Client` and exposes an `Account` instance.

**Verifiable result:** `AppwriteService.ping()` returns 200 from the local Appwrite instance in an integration test.

### 3.2 Auth Screens — Login

- [ ] **3.2.1** Implement `LoginScreen` matching `ui_design/login/code.html`:
  - Atmospheric background (blurred orbs + grain).
  - Glassmorphism card with email + password fields using `LumiTextField`.
  - Primary CTA "Enter the Sanctuary" button using `LumiButton`.
  - "Forgot?" link → `ForgotPasswordScreen`.
  - "New to the sanctuary?" → `SignUpScreen`.
- [ ] **3.2.2** Implement `AuthNotifier` / `AuthBloc` that calls `AppwriteService.login(email, password)`.
- [ ] **3.2.3** On success: navigate to `HomeScreen`. On failure: show inline error snackbar.

**Tests:**
- Widget test: renders all form fields and buttons.
- Widget test: displays error message when login fails.
- Integration test: successful login with valid Appwrite credentials navigates to Home.

### 3.3 Auth Screens — Sign Up

- [ ] **3.3.1** Implement `SignUpScreen` matching `ui_design/sign_up/code.html`:
  - Two-column layout (editorial left column hidden on mobile, form right column).
  - Fields: Full Name, Email, Password, Terms checkbox.
  - Calls `AppwriteService.createAccount(name, email, password)`.
- [ ] **3.3.2** On success: auto-login and navigate to `HomeScreen`.
- [ ] **3.3.3** Validate: email format, password min 8 chars, terms must be checked.

**Tests:**
- Widget test: validation errors display correctly for each field.
- Widget test: CTA is disabled until terms checkbox is checked.
- Integration test: new account created in local Appwrite, then navigated to Home.

### 3.4 Auth Screens — Forgot Password

- [ ] **3.4.1** Implement `ForgotPasswordScreen` matching `ui_design/forgot_password/code.html`:
  - Asymmetric layout (editorial left, recovery card right).
  - Calls `AppwriteService.sendPasswordReset(email)`.
- [ ] **3.4.2** Show success state ("Check your inbox") after submission.

**Tests:**
- Widget test: success message shown after form submit.
- Integration test: password reset email delivered to Mailhog.

### 3.5 Auth Guard & Router

- [ ] **3.5.1** Configure `go_router` with a `redirect` guard: unauthenticated users are sent to `/login`; authenticated users skip auth screens.
- [ ] **3.5.2** Persist Appwrite session across app restarts using the SDK's built-in session storage.

**Tests:**
- Widget test: unauthenticated app state redirects to LoginScreen.
- Widget test: authenticated app state renders HomeScreen.

---

## 4. Flutter Screen Shells (Mock Data)

> All screens in this phase use hardcoded mock data. Real data pipelines arrive in Phase 3.

### 4.1 Home Screen ("Lumi AI")

- [ ] **4.1.1** Implement `HomeScreen` matching `ui_design/home/code.html`:
  - Fixed glassmorphism top app bar ("Lumi AI" + menu/settings icons).
  - Kit the Fox ghost mascot in center (opacity 40%).
  - Chat bubble list: Kit message bubble (left-aligned, `surface-container-lowest`, rounded except top-left) + User bubble (right-aligned, `primary` background).
  - Floating glassmorphism chat input bar at bottom (pill shape, `add` icon, text field "Whisper to Lumi…", `mic` icon CTA).
  - Atmospheric background orbs.

**Tests:**
- Widget test: Kit bubble and user bubble render with correct alignment.
- Widget test: Chat input bar is pinned to bottom and does not scroll with content.

### 4.2 Dashboard Screen ("The Tundra")

- [ ] **4.2.1** Implement `DashboardScreen` matching `ui_design/dashboard/code.html`:
  - Fixed glassmorphism top app bar with "The Tundra" title and top nav links.
  - 3-column bento grid (1-col on mobile) with:
    - **Current Expenses** card: large dollar amount + trend indicator.
    - **Working Hours** card: amount + SVG circular progress ring.
    - **Mileage Tracking** card: miles + estimated IRS deduction.
  - **Recent Activity** section: list of transaction rows (icon + name + amount, no dividers, tonal hover state).
  - Bottom nav bar shell.

**Tests:**
- Widget test: bento grid renders in 3 columns on wide viewport, 1 column on narrow.
- Widget test: each metric card displays its mock value.
- Golden test: dashboard layout matches approved screenshot.

### 4.3 Settings Screen ("The Cabin")

- [ ] **4.3.1** Implement `SettingsScreen` matching `ui_design/settings/code.html`:
  - Back arrow + "The Cabin" title in app bar.
  - User profile section: avatar ring (gradient border), name, email.
  - Workspace settings list: Account Preferences, Security, Notifications (with badge "3 New") — all navigating to placeholder screens.
  - Logout and Delete Account buttons.

**Tests:**
- Widget test: logout button triggers `AppwriteService.logout()` and redirects to Login.
- Widget test: Notifications row displays the "3 New" badge.

---

## 5. FRB v2 Bridge — Proof of Concept

### 5.1 Rust Core Scaffold

- [ ] **5.1.1** In `rust/lumi_core/src/lib.rs`, define and expose a `ping()` function via FRB:
  ```rust
  pub fn ping() -> String { "pong".to_string() }
  ```
- [ ] **5.1.2** Run `flutter_rust_bridge_codegen generate` and confirm Dart bindings appear in `lib/shared/bridge/`.
- [ ] **5.1.3** Call `ping()` from Dart and display the result in a dev-only diagnostics screen.

**Verifiable result (latency test):**
- Integration test calls `ping()` in a loop of 1000 iterations, asserts p99 round-trip < 2 ms.

### 5.2 SQLite Initialization (sea-orm)

- [ ] **5.2.1** Add `sea-orm` with SQLite backend and `sqlx` to `rust/Cargo.toml`.
- [ ] **5.2.2** Define initial schema (migrations via `sea-orm-migration`):
  - `transactions` table: `id`, `amount`, `currency`, `vendor`, `category`, `timestamp`, `receipt_path`, `is_tagged`, `sha256_hash`.
  - `mileage_logs` table: `id`, `distance_miles`, `start_lat`, `start_lng`, `end_lat`, `end_lng`, `timestamp`, `deduction_amount`.
  - `users` table: `id`, `appwrite_user_id`, `display_name`.
- [ ] **5.2.3** Expose `db_init()` via FRB; call it at app startup before rendering any authenticated screen.

**Tests:**
- Rust unit test: `db_init()` creates all tables without error.
- Rust unit test: inserting and querying a mock transaction round-trips correctly.

### 5.3 LanceDB Initialization

- [ ] **5.3.1** Add `lancedb` to `rust/Cargo.toml`.
- [ ] **5.3.2** Create a `vector_db_init(db_path: String)` function exposed via FRB that opens/creates a LanceDB at the app's data directory.
- [ ] **5.3.3** Define the `transaction_embeddings` table schema: `id` (string), `embedding` (vector float32[768]), `metadata` (string/JSON).

**Tests:**
- Rust unit test: `vector_db_init()` creates the database file without error.
- Rust unit test: insert one dummy embedding and retrieve it by ID.

---

## 6. Test Infrastructure & Automation

### 6.1 Docker Compose for Appwrite

- [ ] **6.1.1** Create `docker-compose.appwrite.yml` at the project root with:
  - `appwrite` service (latest image), mapped to port 80.
  - `appwrite-realtime`, `appwrite-worker-usage`, `appwrite-worker-audits`, `appwrite-worker-mails` worker services.
  - `mariadb:10.7` with a named volume `appwrite-mariadb`.
  - `redis:7` with a named volume `appwrite-redis`.
  - `mailhog/mailhog` mapped to ports 1025 (SMTP) and 8025 (web UI).
  - All services on a shared `appwrite-network` bridge.
- [ ] **6.1.2** Add the following entries to `.gitignore`:
  ```
  .env.test
  .vscode/mcp.json
  ```
- [ ] **6.1.3** Add `scripts/wait-for-appwrite.sh`:
  ```bash
  #!/usr/bin/env bash
  until curl -sf http://localhost/v1/health > /dev/null; do
    echo "Waiting for Appwrite..."
    sleep 2
  done
  echo "✓ Appwrite is ready"
  ```

**Verifiable result:** `docker compose -f docker-compose.appwrite.yml up -d && bash scripts/wait-for-appwrite.sh` exits cleanly within 60 s.

### 6.2 Appwrite MCP Configuration

- [ ] **6.2.1** Document the one-time MCP setup in `README.md` under a "Development Setup" section:
  1. Install `uv`: `curl -LsSf https://astral.sh/uv/install.sh | sh`
  2. Create `.vscode/mcp.json` from the template in `IMPLEMENTATION_PLAN.md`.
  3. Start Appwrite, open Copilot in agent mode, and run the bootstrap prompt.
- [ ] **6.2.2** Create `.vscode/mcp.json.template` (committed, no secrets):
  ```json
  {
    "servers": {
      "appwrite": {
        "command": "uvx",
        "args": ["mcp-server-appwrite"],
        "env": {
          "APPWRITE_ENDPOINT": "http://localhost/v1",
          "APPWRITE_PROJECT_ID": "lumi-test",
          "APPWRITE_API_KEY": "<replace-after-bootstrap>"
        }
      }
    }
  }
  ```
- [ ] **6.2.3** Add `.vscode/mcp.json` (the real file with the key) to `.gitignore`.

### 6.3 Appwrite Bootstrap Script (via MCP)

- [ ] **6.3.1** Document the exact Copilot agent prompt to use for bootstrap (store in `scripts/BOOTSTRAP.md`):
  ```
  Using the appwrite MCP server, perform the following steps in order.
  Confirm each step before proceeding to the next.

  1. Create a project with ID "lumi-test" and name "Lumi Test".
  2. Create an API key with all available scopes. Print the key.
  3. Enable the Email/Password authentication method.
  4. Add a Flutter platform with bundle ID "com.lumi.app".
  5. Configure SMTP: host=mailhog, port=1025, sender=noreply@lumi.test, TLS=false.
  6. Create a user with email "test@lumi.com", password "TestPass123!", name "Test User".
  7. Create a user with email "reset@lumi.com", password "TestPass123!", name "Reset User".
  8. Write a file ".env.test" at the project root with the following content,
     substituting the actual project ID and API key:
     APPWRITE_ENDPOINT=http://localhost/v1
     APPWRITE_PROJECT_ID=lumi-test
     APPWRITE_API_KEY=<key-from-step-2>
     TEST_USER_EMAIL=test@lumi.com
     TEST_USER_PASSWORD=TestPass123!
     TEST_RESET_EMAIL=reset@lumi.com
     MAILHOG_URL=http://localhost:8025
  ```
- [ ] **6.3.2** After bootstrap, copy the generated API key into `.vscode/mcp.json` (replacing the template placeholder).

**Verifiable result:** After running the bootstrap prompt, `.env.test` exists and `curl http://localhost/v1/projects/lumi-test` returns 200.

### 6.4 CI Bootstrap Script (REST, no MCP)

- [ ] **6.4.1** Create `scripts/ci-appwrite-bootstrap.sh` for use in GitHub Actions (no MCP runtime available):
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ENDPOINT="http://localhost/v1"
  API_KEY="${APPWRITE_API_KEY}"   # from GitHub secret

  # Create test users via Appwrite REST
  curl -sf -X POST "$ENDPOINT/users" \
    -H "x-appwrite-project: lumi-test" \
    -H "x-appwrite-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","email":"test@lumi.com","password":"TestPass123!","name":"Test User"}'

  curl -sf -X POST "$ENDPOINT/users" \
    -H "x-appwrite-project: lumi-test" \
    -H "x-appwrite-key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"userId":"reset-user","email":"reset@lumi.com","password":"TestPass123!","name":"Reset User"}'

  # Write .env.test
  cat > .env.test <<EOF
  APPWRITE_ENDPOINT=http://localhost/v1
  APPWRITE_PROJECT_ID=lumi-test
  APPWRITE_API_KEY=${API_KEY}
  TEST_USER_EMAIL=test@lumi.com
  TEST_USER_PASSWORD=TestPass123!
  TEST_RESET_EMAIL=reset@lumi.com
  MAILHOG_URL=http://localhost:8025
  EOF
  echo "✓ .env.test written"
  ```

### 6.5 Integration Test Helpers

- [ ] **6.5.1** Create `integration_test/helpers/appwrite_test_client.dart`:
  ```dart
  import 'package:appwrite/appwrite.dart';

  Client buildTestClient() {
    return Client()
      ..setEndpoint(const String.fromEnvironment('APPWRITE_ENDPOINT'))
      ..setProject(const String.fromEnvironment('APPWRITE_PROJECT_ID'));
  }
  ```
- [ ] **6.5.2** Create `integration_test/helpers/test_fixtures.dart`:
  - `Future<Session> createTestSession()` — calls `account.createEmailPasswordSession` with env vars.
  - `Future<void> clearTestSessions()` — calls `account.deleteSessions()` to clean up.
  - `Future<String> waitForEmail(String to, {Duration timeout = const Duration(seconds: 10)})` — polls `GET http://localhost:8025/api/v2/messages` until a message addressed to `to` appears; returns the message body.
- [ ] **6.5.3** Create `integration_test/helpers/flutter_driver_utils.dart`:
  - `Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {Duration timeout})` — pumps frames until the finder resolves or timeout.

### 6.6 Integration Test Files — Auth Suite

- [ ] **6.6.1** `integration_test/auth/login_test.dart`:
  - `setUp`: clear test sessions.
  - Test "valid credentials → navigates to HomeScreen".
  - Test "invalid password → shows inline error, stays on LoginScreen".
  - Test "empty email → validation error displayed".

- [ ] **6.6.2** `integration_test/auth/signup_test.dart`:
  - Uses a unique email per run (`${uuid()}@lumi-test.com`) to avoid conflicts.
  - Test "create account → auto-logged in → HomeScreen shown".
  - Test "duplicate email → shows error".
  - Test "unchecked terms → CTA disabled".
  - `tearDown`: delete the created test user via Appwrite MCP REST call.

- [ ] **6.6.3** `integration_test/auth/forgot_password_test.dart`:
  - Test "submit reset@lumi.com → success state shown".
  - Test "password reset email delivered to Mailhog" — calls `waitForEmail('reset@lumi.com')`, asserts non-empty body.

- [ ] **6.6.4** `integration_test/auth/auth_guard_test.dart`:
  - Test "unauthenticated cold start → redirected to LoginScreen".
  - Test "authenticated cold start → HomeScreen rendered".

### 6.7 Makefile

- [ ] **6.7.1** Create `Makefile` at the project root:
  ```makefile
  DEVICE ?= emulator-5554

  .PHONY: services-up services-down services-reset \
          test-unit test-integration appwrite-reset codegen

  services-up:
  	docker compose -f docker-compose.appwrite.yml up -d
  	@bash scripts/wait-for-appwrite.sh

  services-down:
  	docker compose -f docker-compose.appwrite.yml down

  services-reset:
  	docker compose -f docker-compose.appwrite.yml down -v
  	$(MAKE) services-up

  codegen:
  	flutter_rust_bridge_codegen generate

  test-unit:
  	flutter test test/

  test-integration: services-up
  	flutter test integration_test/ \
  	  --dart-define-from-file=.env.test \
  	  -d $(DEVICE)

  appwrite-reset: services-reset
  	@echo ""
  	@echo "Appwrite volumes wiped. Re-run bootstrap:"
  	@echo "  Open Copilot agent mode and use the prompt in scripts/BOOTSTRAP.md"
  	@echo ""
  ```

**Verifiable result:** `make test-integration DEVICE=emulator-5554` (with Appwrite running and `.env.test` present) executes the full auth integration test suite and exits 0.

---

## Phase 1 — Acceptance Criteria

| # | Criterion | How to Verify |
|---|---|---|
| P1-1 | Flutter app builds for iOS and Android with no errors | `flutter build apk` + `flutter build ios --no-codesign` succeed |
| P1-2 | FRB v2 round-trip latency p99 < 2 ms | Integration test `bridge_latency_test.dart` |
| P1-3 | Login/Sign Up/Forgot Password flows work against local Appwrite | `make test-integration` auth suite passes |
| P1-4 | Auth guard redirects unauthenticated users | `auth_guard_test.dart` passes |
| P1-5 | All 6 screens render without runtime errors (mock data) | Smoke widget tests per screen |
| P1-6 | SQLite schema created and CRUD round-trip passes | Rust unit tests |
| P1-7 | LanceDB initialized and dummy embedding stored/retrieved | Rust unit tests |
| P1-8 | Design token theme matches DESIGN.md golden | `ThemeShowcase` golden test |
| P1-9 | `docker-compose.appwrite.yml` starts clean and Appwrite is healthy within 60 s | `make services-up` exits 0 |
| P1-10 | Appwrite MCP bootstrap creates project, users, and `.env.test` without manual console steps | Run bootstrap prompt in Copilot agent mode; verify `.env.test` exists and API returns 200 |
| P1-11 | Password-reset email delivered to Mailhog in integration test | `forgot_password_test.dart` `waitForEmail` assertion passes |
| P1-12 | `make test-integration` is a single command that boots, tests, and reports | Full pipeline run from cold start |
