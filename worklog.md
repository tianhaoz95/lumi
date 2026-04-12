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

Notes:
- If integration test environment can't run (Appwrite not running locally), create a lightweight unit test or test helper that demonstrates AppwriteService initialization in a test context.
- Do not remove worklog.md after completion; reviewer will verify and request changes if needed.
