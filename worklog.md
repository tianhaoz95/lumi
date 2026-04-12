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

Summary of verification actions:
- Inspected files: lib/widgets/kit_animated.dart, lib/shared/widgets/kit_animated.dart, lib/features/home/home_impl.dart, test/widgets/kit_animated_test.dart.
- Ran repository checks (file listing, grep, content inspection) in this environment.
- Attempted to run widget tests but `flutter` is not installed in this review environment; tests could not be executed here.

Findings:
1) lib/widgets/kit_animated.dart — VERIFIED
- File exists and defines `KitAnimated` with the expected public API. The constructor supports both an explicit `state` (KitState enum) and a backward-compatible `isProcessing` boolean. The widget includes the keyed element `Key('kit-fox-base')` used by tests.

2) Duplicate implementations — ACTION RECOMMENDED (important)
- A second KitAnimated implementation exists at lib/shared/widgets/kit_animated.dart. Both implementations expose similar APIs but differ in details (one is more feature-rich). This duplication risks future divergence and confusion.
- Recommendation: choose a canonical implementation (suggest lib/widgets/kit_animated.dart), remove the duplicate, or provide a small re-export shim in the old location that forwards to the canonical file to avoid breaking imports.

3) HomeScreen imports and usage — VERIFIED
- HomeScreen (lib/features/home/home_impl.dart) imports the package-level KitAnimated (import 'package:lumi/widgets/kit_animated.dart') and uses KitAnimated(...) in the empty state and chat area wired to the `_isStreaming` flag.
- No active reference to KitGhost remains in the runtime code paths. If any legacy imports (kit_ghost) remain elsewhere, remove them.

4) Tests — NOT EXECUTABLE HERE (please run in CI)
- test/widgets/kit_animated_test.dart exists and contains two widget tests (Thinking state and Found one-shot completion).
- This environment does not have Flutter installed; therefore the reviewer could not run `flutter test`. Worker must run tests locally or in CI and provide passing results before final acceptance.

5) Phase checklist
- design/roadmap/phase-5-aurora.md has been updated to uncheck item 2.2.2 so the worker can address duplication and test verification. (See change in roadmap.)

Commands run by reviewer (local checks in repo):
- Listed files in lib/widgets and lib/shared/widgets; observed both kit_animated.dart files present.
- Inspected lib/features/home/home_impl.dart and confirmed import: package:lumi/widgets/kit_animated.dart and usage of KitAnimated(isProcessing: _isStreaming, ...).
- Attempted `flutter --version`/`flutter test` but flutter is not available in this environment; tests not executed here.

Required fixes before final acceptance:
1. Consolidate KitAnimated implementations (remove duplicate or re-export canonical symbol). Update imports.
2. Run `flutter test test/widgets/kit_animated_test.dart` in CI or locally and confirm all tests pass; include CI link or test output in next update.
3. After consolidation and tests passing, mark 2.2.2 as complete in design/roadmap/phase-5-aurora.md.

Acceptance decision:
- Not accepted yet. Functional behavior is present, but repository hygiene (duplicate implementations) and missing verifiable test execution prevent final acceptance. Please address the three required fixes and re-submit.

Worker Actions (by this agent)
--------------------------
- Addressed reviewer required fix #1: consolidated duplicate KitAnimated implementations.
  - Replaced the implementation at lib/shared/widgets/kit_animated.dart with a re-export to the canonical implementation at lib/widgets/kit_animated.dart.
  - Verified the re-export file contents.
- Verification steps performed here (repo checks only):
  - Confirmed canonical implementation at lib/widgets/kit_animated.dart remains intact.
  - Confirmed lib/shared/widgets/kit_animated.dart now re-exports the canonical file.
  - Confirmed HomeScreen already imports package:lumi/widgets/kit_animated.dart per reviewer notes.
- Remaining required action that cannot run in this environment:
  - Running `flutter test test/widgets/kit_animated_test.dart` is required to prove the widget tests pass. Flutter is not installed in this execution environment. Please run the tests in CI or locally and paste the output in the reviewer comment.

Reviewer: Automated code-review agent
Date: 2026-04-12
