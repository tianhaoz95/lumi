Task: 2.1.2 — Replace hardcoded animation durations with LumiAnimations constants

Planned steps:
1. Search the codebase for usages of AnimatedContainer, AnimationController, TweenAnimationBuilder, and any literal Duration(...) uses.
2. Create or locate lib/core/animations.dart (LumiAnimations) if missing; otherwise confirm the existing class and its API.
3. Replace hardcoded Duration(...) and direct Curves usage with LumiAnimations constants where appropriate (driftDuration, driftCurve, snapDuration, snapCurve).
4. Run Flutter analyzer and existing widget tests to ensure no breakage when environment allows; otherwise validate changes with grep and targeted checks.
5. Commit changes and update roadmap to mark task done once verifiable deliverables pass.

Verifiable deliverables:

Status (this run):
- worklog.md existed (from a previous run); updating with current fixes.
- Implemented fixes requested by reviewer:
  - Added `LumiAnimations.noTransition = Duration.zero` in lib/core/lumi_animations.dart.
  - Replaced literal `Duration.zero` in lib/features/loading/loading_screen.dart with `LumiAnimations.noTransition`.
  - Removed unused import of atmospheric_background from lib/features/auth/forgot_password_screen.dart.
  - Replaced deprecated `withOpacity(...)` usage in lib/shared/widgets/atmospheric_background.dart with an explicit `withAlpha((opacity * 255).round())` call.
- Verification (quick checks):
  - `Duration.zero` now only appears as `LumiAnimations.noTransition` in lib/core/lumi_animations.dart.
  - AnimatedContainer and AnimationController usages reference `LumiAnimations` constants (see lib/shared/widgets/lumi_text_field.dart, lib/features/auth/login_screen.dart, lib/core/app.dart).
  - Deprecated withOpacity usage in atmospheric_background.dart fixed; remaining `withOpacity` occurrences elsewhere carry explicit ignore comments and are outside the scope of this task.
- Next steps: run `flutter analyze --no-pub` in an environment with Flutter to catch any analyzer warnings; reviewer may re-run analyzer. If further issues appear, they will be addressed.

Verifiable deliverables:
- File `worklog.md` exists and lists the task, plan, and deliverables.
- All occurrences of hardcoded durations in UI animation APIs (AnimatedContainer, TweenAnimationBuilder, AnimationController initializations) are replaced to reference `LumiAnimations` constants.
- `lib/core/animations.dart` (or `lib/core/lumi_animations.dart`) exists and exports the four constants.
- No new animation-related analyzer errors introduced by these edits (pre-existing analyzer issues may remain).
- A grep showing zero remaining usages of `Duration(Duration(milliseconds:` or literal Duration(...) in animation contexts (except tests) — reviewer can run `grep` to confirm.

Notes:
- Micro-snaps (<=150ms) are allowed; mapping will use `snapDuration` for those.
- This work focuses only on replacing durations/curves with constants, not changing animation semantics.

Reviewer Findings:

- SUMMARY: Not all verifiable deliverables are satisfied. A literal Duration usage remains in a UI animation context (lib/features/loading/loading_screen.dart), and two non-fatal analyzer issues remain (an unused import and a deprecated API use). Steps required are listed below.

1) Remaining literal Duration in UI code
  * File: lib/features/loading/loading_screen.dart
  * Location: inside Navigator fallback → PageRouteBuilder(..., transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero)
  * Explanation: The task required replacing hardcoded Duration(...) usages in UI animation APIs with LumiAnimations constants. Duration.zero in this UI file is a literal and was not replaced. Grep shows the following Duration-related hits in lib/:
    - lib/core/lumi_animations.dart (allowed central constants)
    - lib/features/loading/loading_screen.dart (transitionDuration: Duration.zero)  <-- needs attention
    - lib/shared/bridge/transactions_bridge.dart (bridge delays — allowed)
    - lib/shared/bridge/summary_bridge.dart (bridge delays — allowed)
    - lib/features/auth/appwrite_service.dart (service ping timeout — allowed)
  * Recommendation / Fix: Replace the literal Duration.zero with an appropriate LumiAnimations constant or introduce an explicit LumiAnimations.noTransition = Duration.zero if the codebase prefers centralization. Example options:
    - If the intent is no transition: create LumiAnimations.noTransition = Duration.zero and use that.
    - If the intent is a short fade, use LumiAnimations.fadeDuration (already present) or LumiAnimations.driftDuration.
  * After change: re-run the grep checks to confirm no remaining literal Duration(...) in UI animation contexts.

2) Analyzer findings (non-animation)
  * Command run: flutter analyze --no-pub
  * Output (current):
    - warning • Unused import: '../../shared/widgets/atmospheric_background.dart' • lib/features/auth/forgot_password_screen.dart:7:8 • unused_import
    - info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss • lib/shared/widgets/atmospheric_background.dart:104:57 • deprecated_member_use
  * Recommendation / Fix:
    - Remove the unused import in lib/features/auth/forgot_password_screen.dart (line shown above) or reference the symbol if intended.
    - Replace the deprecated .withOpacity(...) usage in lib/shared/widgets/atmospheric_background.dart with the recommended .withValues() call per the analyzer suggestion.
  * Note: These issues are non-fatal and unrelated to animations, but they should be fixed before marking the task complete.

3) Curves usage verification
  * Grep for `Curves.` across lib/ shows occurrences only in lib/core/lumi_animations.dart. This is correct and meets the deliverable to centralize curve constants.

Action items (concrete):
  1. Replace the literal Duration.zero in lib/features/loading/loading_screen.dart with a LumiAnimations constant (suggest LumiAnimations.noTransition = Duration.zero or LumiAnimations.fadeDuration depending on intended behavior).
  2. Remove the unused import from lib/features/auth/forgot_password_screen.dart (or use the imported symbol) to clear the analyzer warning.
  3. Update lib/shared/widgets/atmospheric_background.dart to stop using the deprecated withOpacity API (use .withValues()).
  4. Re-run: `flutter analyze --no-pub` and the grep commands used originally:
     - grep -R "Duration" lib/ | grep -v "core/lumi_animations.dart" | grep -n --color=never .
     - grep -R "Curves\." lib/
     Confirm there are no remaining literal Duration(...) usages in UI animation contexts and Curves usage is centralized.
  5. Update worklog.md with the new verification results and only then re-check off `2.1.2` in design/roadmap/phase-5-aurora.md.

Reviewer: Automated code-review agent
Date: 2026-04-12T22:50:07.581Z

Status: Not accepted — revisions required. Please make the changes above and notify when ready for re-review.

