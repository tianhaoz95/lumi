Task: Button Theming — Implement LumiPrimaryButton and LumiSecondaryButton

Planned steps:
1. Inspect existing theme tokens in lib/core/theme.dart to identify primary and primaryContainer colors.
2. Create a new widget file at lib/widgets/lumi_buttons.dart that defines:
   - LumiPrimaryButton: a reusable Elevated-like button with a 135-degree linear gradient from `primary` to `primaryContainer`, full-pill radius, and consistent padding.
   - LumiSecondaryButton: a glassmorphism-styled button with 40% white overlay, 12px backdrop blur, semi-transparent border, and pill shape.
3. Wire the new widgets by exporting them from lib/widgets/widgets.dart (create file if missing) and import in places that may use them later.
4. Run a quick `flutter analyze` (if available) or `dart pub get` to surface obvious errors.
5. Ensure files compile by running `flutter analyze` locally (reviewer will run full build).

Verifiable deliverables:
- worklog.md exists and contains the planned steps and deliverables (this file).
- File lib/shared/widgets/lumi_buttons.dart exists and defines classes `LumiPrimaryButton` and `LumiSecondaryButton`.
- File lib/core/theme.dart contains color tokens `primary` and `primaryContainer` (or equivalent names) for the gradient to reference.
- A small static example widget is present in lib/shared/widgets/lumi_buttons.dart showing usage in a `StatelessWidget` named `LumiButtonsPreview` (so reviewer can visually inspect and run a short app to see both buttons).
- The duplicate file `lib/widgets/lumi_buttons.dart` has been removed; `lib/widgets/widgets.dart` now re-exports the shared implementation.
- `lib/shared/widgets/lumi_button.dart` default gradient has been corrected to a 135-degree gradient (Alignment.topLeft → Alignment.bottomRight).
- Changes have been committed to git (see commit message referencing this work).

## Reviewer Findings (resolved)
1. Gradient Direction: Resolved. The default gradient in `lib/shared/widgets/lumi_button.dart` now uses `begin: Alignment.topLeft` and `end: Alignment.bottomRight` (135°).
2. Duplicate Implementation Files: Resolved. Removed `lib/widgets/lumi_buttons.dart` and updated export in `lib/widgets/widgets.dart` to re-export `../shared/widgets/lumi_buttons.dart`.
3. Stale Information: Addressed. This worklog has been updated to reflect the current repository state and actions taken.
4. Task Marking Inconsistency: Addressed. The `LumiPrimaryButton` subtask in `midterm-polish-tasks.md` has been marked complete; remaining subtasks remain for future work.
