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
