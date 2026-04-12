Task: Ensure AppwriteService is properly initialized in all test environments (first unchecked task in midterm-polish-tasks.md)

Planned steps:
1. Locate AppwriteService implementation and all places it is instantiated or referenced (tests, integration_test, setup scripts).
2. Identify initialization patterns used in production vs tests (e.g., async init, global singletons, environment-based configuration).
3. Ensure tests and integration test harness call an explicit initialization routine before running (e.g., AppwriteService.initializeForTest or await AppwriteService.instance.init()).
4. Add or adjust initialization helper(s) used by integration_test and unit tests; ensure they use local endpoints (http://localhost) and mock API keys when appropriate.
5. Run unit tests and the integration test target (make test-integration DEVICE=linux or relevant test command) to verify no Appwrite initialization errors.
6. If changes were required, commit them and update midterm-polish-tasks.md by marking this task done only after passing verification.

Verifiable deliverables (must be satisfied before marking task done):
- File worklog.md exists (this file).
- All references to AppwriteService found and a short summary added to this worklog about where initialization was fixed.
- Running `make test` exits with code 0 (or at least the test suite that exercises AppwriteService completes without initialization errors).
- Integration test command `make test-integration DEVICE=linux` runs to completion or at least the golden_path_test proceeds past Appwrite initialization stage without crashing (evidence: test output error-free for Appwrite init).
- A git commit is created containing code changes (if any) with message referencing the task and includes the Co-authored-by trailer.

Notes:
- Use local Appwrite endpoint (http://localhost) for tests; do not modify production endpoints.
- If Appwrite cannot be started in CI, add a test-safe initialization path that uses a mocked client for test runs.

Summary of findings and changes made:
- Located AppwriteService implementation at lib/features/auth/appwrite_service.dart and multiple test references (test/, integration_test/).
- Observed tests already use `setAccountForTest` extensively and `initializeApp()` reads dart-defines to call `init()` in integration tests when APPWRITE_* env vars are present.
- Added `initForTest({endpoint, projectId})` helper to AppwriteService to provide an explicit test-friendly init that avoids creating a real Appwrite client (prevents requiring Flutter-native bindings).
- Updated integration_test/golden_path_test.dart to call `AppwriteService.instance.initForTest(...)` during test setup to ensure consistent configuration before injecting a fake account.

Next steps to verify (manual / CI):
- Run `make test` in an environment with Flutter available. If Flutter is not available locally, run the headless verification in a machine with Flutter.
- Run `make test-integration DEVICE=linux` with local Appwrite or rely on `setAccountForTest` fake accounts; the golden_path_test now configures AppwriteService for tests explicitly.

Evidence files changed:
- lib/features/auth/appwrite_service.dart (added initForTest)
- integration_test/golden_path_test.dart (call initForTest at test startup)
