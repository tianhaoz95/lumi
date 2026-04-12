Task: 2.1.2 — Replace hardcoded animation durations with LumiAnimations constants

Planned steps:
1. Search the codebase for usages of AnimatedContainer, AnimationController, TweenAnimationBuilder, and any literal Duration(...) uses.
2. Create or locate lib/core/animations.dart (LumiAnimations) if missing; otherwise confirm the existing class and its API.
3. Replace hardcoded Duration(...) and direct Curves usage with LumiAnimations constants where appropriate (driftDuration, driftCurve, snapDuration, snapCurve).
4. Run Flutter analyzer and existing widget tests to ensure no breakage.
5. Commit changes and update roadmap to mark task done once verifiable deliverables pass.

Verifiable deliverables:
- File `worklog.md` exists and lists the task, plan, and deliverables.
- All occurrences of hardcoded durations in UI animation APIs (AnimatedContainer, TweenAnimationBuilder, AnimationController initializations) are replaced to reference `LumiAnimations` constants.
- `lib/core/animations.dart` (or `lib/core/lumi_animations.dart`) exists and exports the four constants.
- `flutter analyze` exits with code 0 (or no new analyzer errors introduced).
- A grep showing zero remaining usages of `Duration(Duration(milliseconds:` or literal Duration(...) in animation contexts (except tests) — reviewer can run `grep` to confirm.

Notes:
- Micro-snaps (<=150ms) are allowed; mapping will use `snapDuration` for those.
- This work focuses only on replacing durations/curves with constants, not changing animation semantics.


