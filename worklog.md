Task: 2.2.2 — Replace static KitGhost widget in HomeScreen with animated Kit widget (KitAnimated)

Planned steps:
1. Locate HomeScreen and the existing KitGhost widget references in the Flutter app (search lib/).
2. Implement a minimal, testable KitAnimated widget at lib/widgets/kit_animated.dart that supports states: idle and thinking via an `isProcessing` boolean. Keep implementation lightweight (no heavy Lottie dependency) but structured so it can be swapped for a real animation later.
3. Replace KitGhost usage in HomeScreen with KitAnimated and wire `isProcessing` to the agent_chat stream flag (or a local placeholder boolean if stream integration is nontrivial).
4. Add a widget test ensuring KitAnimated switches from idle -> thinking when `isProcessing` toggles.
5. Run `flutter test` (or existing test commands) and ensure the new test passes.
6. Commit changes and mark the task done in phase-5-aurora.md only after all deliverables pass.

Verifiable deliverables:
- File exists: lib/widgets/kit_animated.dart and contains a KitAnimated widget with an `isProcessing` constructor parameter.
- HomeScreen now imports and uses KitAnimated instead of KitGhost (file change can be reviewed with git diff).
- Widget test: test/widgets/kit_animated_test.dart exists and passes (`flutter test` returns exit code 0).
- Phase file updated: the line for 2.2.2 in design/roadmap/phase-5-aurora.md is changed from '- [ ]' to '- [x]'.

Notes:
- The KitAnimated implementation is intentionally lightweight to avoid introducing new heavy dependencies and to keep performance safe during tests. It is a functional placeholder that meets interface and testability requirements.

Task: 2.2.2 — Replace static KitGhost widget in HomeScreen with animated Kit widget (KitAnimated)

Planned steps:
1. Locate HomeScreen and the existing KitGhost widget references in the Flutter app (search lib/).
2. Implement a minimal, testable KitAnimated widget at lib/widgets/kit_animated.dart that supports states: idle and thinking via an `isProcessing` boolean. Keep implementation lightweight (no heavy Lottie dependency) but structured so it can be swapped for a real animation later.
3. Replace KitGhost usage in HomeScreen with KitAnimated and wire `isProcessing` to the agent_chat stream flag (or a local placeholder boolean if stream integration is nontrivial).
4. Add a widget test ensuring KitAnimated switches from idle -> thinking when `isProcessing` toggles.
5. Run `flutter test` (or existing test commands) and ensure the new test passes.
6. Commit changes and mark the task done in phase-5-aurora.md only after all deliverables pass.

Verifiable deliverables:
- File exists: lib/widgets/kit_animated.dart and contains a KitAnimated widget with an `isProcessing` constructor parameter.
- HomeScreen now imports and uses KitAnimated instead of KitGhost (file change can be reviewed with git diff).
- Widget test: test/widgets/kit_animated_test.dart exists and passes (`flutter test` returns exit code 0).
- Phase file updated: the line for 2.2.2 in design/roadmap/phase-5-aurora.md is changed from '- [ ]' to '- [x]'.

Notes:
- The KitAnimated implementation is intentionally lightweight to avoid introducing new heavy dependencies and to keep performance safe during tests. It is a functional placeholder that meets interface and testability requirements.

Reviewer Findings
-----------------

Summary:
- lib/widgets/kit_animated.dart exists and exposes KitAnimated with a backwards-compatible `isProcessing` parameter and a keyed base (`Key('kit-fox-base')`).
- HomeScreen imports and uses KitAnimated (wired to `_isStreaming`) and no KitGhost references remain in HomeScreen.
- A re-export exists at lib/shared/widgets/kit_animated.dart to preserve the old import path; duplication was resolved by creating this shim.
- test/widgets/kit_animated_test.dart exists and contains two widget tests covering the thinking state and the found one-shot animation completion.

Outstanding verification / issues (action required):
1) Tests not executed in this environment
- Reason: This review environment does not have Flutter installed; `flutter test` could not be run here. The deliverable requiring a passing widget test (flutter test exit code 0) is therefore unverified.
- Action for worker: Run `flutter test test/widgets/kit_animated_test.dart` locally or in CI (ensure Flutter SDK is available). Paste the full test output (or CI job URL) into the next worklog update. If tests fail, fix and re-run until passing.

2) Phase checklist state
- Reason: Because the widget tests could not be verified, the phase checklist item 2.2.2 must remain open so the worker can supply test results.
- Action for reviewer/worker: After providing test output demonstrating passing tests, update design/roadmap/phase-5-aurora.md to mark 2.2.2 as complete.

3) Duplication (informational, resolved)
- Background: There previously existed two implementations. The repository now contains a canonical implementation at lib/widgets/kit_animated.dart and a re-export shim at lib/shared/widgets/kit_animated.dart. This is an acceptable interim solution.
- Recommendation (optional): Prefer a single canonical implementation and update all imports to use it in future cleanup PR; the re-export shim is fine short-term to avoid churn.

Required next steps (clear, actionable):
- A. Run widget tests:
  1. On a machine or CI with Flutter installed, run:
     flutter test test/widgets/kit_animated_test.dart
  2. Confirm exit code 0 and paste stdout/stderr into the next worklog revision OR provide a CI job link showing success.
- B. If tests fail, run `flutter test --update-goldens` only if golden mismatches are the cause; otherwise fix failing assertions and re-run.
- C. Once test output is provided and passing, update design/roadmap/phase-5-aurora.md to mark 2.2.2 as complete (change - [ ] to - [x]).

Acceptance decision:
- Not accepted yet. All code-level deliverables are present and appear correct by inspection, but the required passing test run could not be verified here. After the worker provides passing test output and marks the phase file accordingly, accept and delete worklog.md.

Reviewer: Automated code-review agent
Date: 2026-04-12

Worker actions:

- Created GitHub Actions workflow `.github/workflows/kit-widget-tests.yml` to run the widget tests on push/pull_request. This allows CI to execute `flutter test test/widgets/kit_animated_test.dart` and provide a job URL and logs the reviewer requested.
- Reason: Flutter is not available in this execution environment, so local `flutter test` could not be run. CI is provided so the reviewer can verify test output and job success.
- Next steps for reviewer:
  1. Inspect the CI run on GitHub (Actions tab) after pushing these commits. The job "Run widget test" runs the single widget test file and exits with code 0 on success.
  2. If CI fails due to golden mismatches, run `flutter test --update-goldens` locally or adjust expectations; re-run CI.

Notes:
- The code-level deliverables (lib/widgets/kit_animated.dart, lib/shared/widgets/kit_animated.dart shim, HomeScreen wiring, and test file) were already added by the prior worker and are present in the repository. This worker did not modify those files.
- The phase checklist item 2.2.2 in design/roadmap/phase-5-aurora.md remains unmarked until CI verifies passing tests. After CI shows success, update the phase file to mark the task done and paste the CI job URL into this worklog.

Status: Awaiting CI test run and reviewer verification.

