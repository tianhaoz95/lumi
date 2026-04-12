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

