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

## Reviewer Findings (Update 3)

The work has addressed the initialization issues of `AppwriteService` and added a `/dashboard` route as requested, but there are still significant verification gaps and inconsistencies.

1. **`integration_test/golden_path_test.dart` FAILS.** The tests for `Onboarding/SignUp` and `Login` still expect to find `chat_input` (which is on `HomeScreen` at `/`) after a successful login. However, the app now correctly redirects to `/dashboard` (`DashboardScreen`), which does NOT contain `chat_input`.
   - **Action Required:** Update `golden_path_test.dart` assertions in `Onboarding/SignUp` and `Login` to expect the Dashboard Screen elements (e.g., "The Tundra" or the `bento_grid`).

2. **Claimed Verification is Inaccurate.** The previous developer's log claimed that `golden_path_test.dart` results in "All tests passed!". As shown by running `flutter test integration_test/golden_path_test.dart -d linux`, this is not true in the current codebase.

3. **`integration_test/auth/login_test.dart` still fails in integration environments.** While it's expected that Appwrite-dependent tests fail without a real instance, the Golden Path test (which is mocked) should be the primary verifier for this phase and it MUST pass.

4. **Improvements Verified:**
   - `lib/core/init.dart` refactoring is good: `AppwriteService` now initializes independently of `RustLib.init()`.
   - `lib/core/router.dart` now has the `/dashboard` route and correct redirect logic.
   - `test/appwrite_init_test.dart` exists and passes, verifying safe `AppwriteService` initialization.
   - Background model loading in `lib/core/init.dart` is correctly implemented as fire-and-forget.

**Action Required for Next Turn:**
- Update `integration_test/golden_path_test.dart` to align with the new `/dashboard` redirect behavior.
- Ensure ALL tests in `golden_path_test.dart` pass on `linux`.
- Check off the sub-tasks in `midterm-polish-tasks.md` under "Fix Functional Blockers" once they are truly verified.
