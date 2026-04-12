Task: 2.2.1 — Create 4 Kit animation states (Idle, Thinking, Found, Alert)

Planned steps:
1. Add a lightweight, asset-free Flutter widget `KitAnimated` that implements the four animation states using AnimationController(s) and simple transforms/opacity so it requires no new asset dependencies.
2. Place the widget in `lib/widgets/kit_animated.dart` with a public API to set state and trigger one-shot animations (Found, Alert).
3. Add a widget test at `test/widgets/kit_animated_test.dart` that pumps the widget, toggles states, and verifies the expected animated transforms/opacity changes.
4. Run `flutter test test/widgets/kit_animated_test.dart` and ensure it exits with code 0.

Verifiable deliverables:
- File `worklog.md` exists and documents plan and deliverables (this file).
- File `lib/widgets/kit_animated.dart` exists and defines `KitAnimated` with enum `KitState` and API to set state.
- File `test/widgets/kit_animated_test.dart` exists and contains at least two widget tests:
  - `KitAnimated` enters `Thinking` state when requested (test pumps and verifies animation is active).
  - `KitAnimated` plays `Found` one-shot animation when triggered.
- Running `flutter test test/widgets/kit_animated_test.dart` exits with code 0.

Notes:
- This work targets only roadmap item 2.2.1 (creating animation states). Integration into HomeScreen and agent wiring (2.2.2–2.2.4) will be addressed in later tasks.
- Implemented animations are intentionally asset-free (no Lottie) to simplify testing and avoid adding large binary assets in this step.
