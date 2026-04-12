Task: 2.1.2 — Replace hardcoded animation durations with LumiAnimations constants

Planned steps:
1. Search the codebase for usages of AnimatedContainer, AnimationController, TweenAnimationBuilder, and any literal Duration(...) uses.
2. Create or locate lib/core/animations.dart (LumiAnimations) if missing; otherwise confirm the existing class and its API.
3. Replace hardcoded Duration(...) and direct Curves usage with LumiAnimations constants where appropriate (driftDuration, driftCurve, snapDuration, snapCurve).
4. Run Flutter analyzer and existing widget tests to ensure no breakage when environment allows; otherwise validate changes with grep and targeted checks.
5. Commit changes and update roadmap to mark task done once verifiable deliverables pass.

Verifiable deliverables:

Status (this run):
- worklog.md created and populated.
- Replaced hardcoded animation durations/curves with LumiAnimations constants in UI code.
- lib/core/lumi_animations.dart exists and provides driftDuration/driftCurve and snapDuration/snapCurve.
- Grep confirms no remaining literal Duration(milliseconds:...) used in UI animation contexts under lib/ (except the central LumiAnimations file and non-UI bridge utilities).

Verifiable deliverables:
- File `worklog.md` exists and lists the task, plan, and deliverables.
- All occurrences of hardcoded durations in UI animation APIs (AnimatedContainer, TweenAnimationBuilder, AnimationController initializations) are replaced to reference `LumiAnimations` constants.
- `lib/core/animations.dart` (or `lib/core/lumi_animations.dart`) exists and exports the four constants.
- No new animation-related analyzer errors introduced by these edits (pre-existing analyzer issues may remain).
- A grep showing zero remaining usages of `Duration(Duration(milliseconds:` or literal Duration(...) in animation contexts (except tests) — reviewer can run `grep` to confirm.

Notes:
- Micro-snaps (<=150ms) are allowed; mapping will use `snapDuration` for those.
- This work focuses only on replacing durations/curves with constants, not changing animation semantics.


