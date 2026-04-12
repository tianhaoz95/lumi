Task: Replace standard Metrics Cards with Glassmorphism containers on the Dashboard

Planned steps:
1. Locate dashboard metric card implementation(s) under lib/ (search for "LumiCard", "Metrics", "dashboard" or card widgets).
2. Create/modify a reusable widget (LumiGlassCard) with glassmorphism: 70% white overlay, backdrop-filter blur 24px (20-40px range), subtle shadow (on-surface 4% alpha), 16px corner radius.
3. Replace usage in dashboard metrics cards to use LumiGlassCard when cards are floating (non-full-bleed).
4. Run static checks (flutter analyze if available) and run any existing Dart tests relevant to widget builds.
5. Verify deliverables and update midterm-polish-tasks.md to mark the task done.

Verifiable deliverables:
- worklog.md exists and contains this plan.
- File lib/features/dashboard/widgets/lumi_glass_card.dart exists and defines a LumiGlassCard widget with opacity and blur parameters (opacity 0.7, blur 24.0).
- One or more dashboard metric card files under lib/features/dashboard/ updated to import and use LumiGlassCard instead of the previous plain Card widget.
- Running `flutter analyze` (or `dart analyze`) exits with code 0 (or no analyzer errors reported in repo). If Flutter isn't available in CI, static Dart analysis shows no errors in modified files.
- midterm-polish-tasks.md updated: the Dashboard Metrics Cards line changed from "- [ ]" to "- [x]".

## Reviewer Findings
1. **Shadow Clipping:** In `lib/shared/widgets/lumi_card.dart`, the `BoxShadow` is defined on the `Container` which is a child of `ClipRRect`. This causes the shadow to be clipped by the `ClipRRect` and thus invisible to the user. To fix this, the shadow should be moved to a `Container` or `PhysicalModel` that wraps the `ClipRRect`.
2. **Sub-bullets Status:** In `midterm-polish-tasks.md`, the sub-bullets under "Metrics Cards" remain unchecked (`- [ ]`), while the parent was previously marked as done (`- [x]`). These should be checked to accurately reflect the completion of the work.
3. **Consistency:** While `LumiGlassCard` was created and used for Metrics Cards, the `Recent Activity` items in `dashboard.dart` still use `LumiCard` directly. While `LumiCard` now has the same defaults as `LumiGlassCard`, the shadow clipping issue (Finding #1) affects both. Consider promoting `LumiCard` as the single source of truth and fixing its implementation, or applying `LumiGlassCard` consistently where glassmorphism is required.
