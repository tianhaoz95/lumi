Task: Fix Functional Blockers (first unchecked task in midterm-polish-tasks.md)

Planned steps:
1. Inspect codebase for AppwriteService initialization and integration test wiring.
2. Ensure AppwriteService is initialized in test environments (integration_test and any test setup helpers).
3. Search for ProviderScope / GoRouter usage to locate potential state issues; add guards or test-specific initialization where needed.
4. Ensure background model loading is non-blocking by checking any synchronous startup calls; convert to async/late init or background isolate if needed.
5. Run available tests (make test-integration DEVICE=linux) or unit tests to verify no blocking behavior.
6. If tests fail, iterate until verifiable deliverables are satisfied.

Verifiable deliverables:
- worklog.md file exists at project root and contains the task, steps, and deliverables above.
- File(s) updated so that AppwriteService is initialized in integration tests: a small change in test setup or a new test helper file (show modified file(s) in git diff).
- ProviderScope / GoRouter state issues addressed: commit includes concrete change(s) (files and lines) that initialize required providers before router creation.
- Background model loading is asynchronous and does not block app startup: confirm by modifying any blocking call to async and adding a comment explaining change.
- Running `make test-integration DEVICE=linux` completes without AppwriteService initialization failures (exit code 0) OR (if integration environment unavailable) a new unit test or script that verifies AppwriteService can be initialized in a headless test and exits 0.

## Reviewer Findings (Update 2)

The work has progressed significantly, but some functional blockers and verification gaps remain.

1. **`golden_path_test.dart` now passes!** The Riverpod override fix (`overrideWith` instead of `overrideWithValue`) was correct and resolved the compilation blocker. Running `flutter test integration_test/golden_path_test.dart -d linux` results in "All tests passed!".

2. **`integration_test/auth/login_test.dart` still fails.** The test expects to find "The Tundra" (the `DashboardScreen` title) after a successful login. However, the app's `GoRouter` redirects to `/` (`HomeScreen`) after login, which displays the text "Lumi AI" instead. This mismatch prevents the test from passing.
   - **Recommendation:** Either update the test to expect "Lumi AI" or add the `/dashboard` route to the `GoRouter` and update the redirect/navigation flow.

3. **`AppwriteService` Initialization is Fragile.** In `lib/core/init.dart`, the `AppwriteService.init` call happens *after* `RustLib.init()`. If `RustLib.init()` fails (common on headless Linux without native models), the entire `initializeApp()` function throws, and the `try-catch` in the tests will skip `AppwriteService` initialization.
   - **Recommendation:** Move `AppwriteService.init` before `RustLib.init()` or wrap the two initialization blocks in separate `try-catch` blocks within `initializeApp()`.

4. **Sub-tasks Not Checked.** The sub-tasks for "Fix Functional Blockers" in `midterm-polish-tasks.md` are still unchecked. Please check them off once the work is verified and the tests pass consistently.

5. **`golden_path_test.dart` marked as done but sub-tasks not all verified.** While the test itself passes now, the sub-tasks in `midterm-polish-tasks.md` (e.g., Onboarding/SignUp, Login, etc.) should be carefully reviewed to ensure they all truly pass on the target platform (Linux/Android).

**Action Required:**
- Fix the navigation/assertion mismatch in `integration_test/auth/login_test.dart`.
- Refactor `lib/core/init.dart` to make `AppwriteService` initialization independent of `RustLib.init()`.
- Ensure `make test-integration DEVICE=linux` passes all tests (or at least the ones expected to run in this phase).
- Mark the sub-tasks as done in `midterm-polish-tasks.md`.

## Developer actions (previous turn)

- Fixed Riverpod override in integration_test/golden_path_test.dart:
  - Replaced authNotifierProvider.overrideWithValue(...) with authNotifierProvider.overrideWith((ref) => _TestAuthNotifier()).
  - Commit: fix(tests): correct Riverpod override and guard initializeApp in integration tests

- Guarded initializeApp() calls in integration_test/auth/login_test.dart to ignore FRB/native library load failures in headless/test environments (wrapped in try/catch).

## Files changed (for reviewer verification)

- integration_test/golden_path_test.dart  (modified: provider override)
- integration_test/auth/login_test.dart (modified: wrapped initializeApp() in try/catch)
