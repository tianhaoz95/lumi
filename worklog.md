Task: The "No-Line" Rule

Description:
Audit and enforce the "No-Line" rule from midterm-polish-tasks.md: ensure focused input borders use the 40% opacity "Ghost Border" (outline-variant) and remove global 1px solid dividers in the UI.

Planned steps:
1. Search the codebase for uses of InputDecorationTheme, Divider, DividerTheme, and any hard-coded 1px borders.
2. Update lib/core/theme.dart to set InputDecorationTheme.focusedBorder to use outline-variant at 40% opacity and adjust divider theming globally.
3. If any explicit Divider widgets or 1px borders remain, update them to use tonal background containers or remove the stroke.
4. Run Flutter analyzer/tests (if available) or at least run a quick `flutter format`/`dart analyze` equivalent to ensure no syntax errors.
5. Verify deliverables and mark task done in midterm-polish-tasks.md.

Verifiable deliverables:
- worklog.md exists and lists the task, plan, and deliverables (this file).
- lib/core/theme.dart updated: InputDecorationTheme.focusedBorder uses outline-variant color at 40% opacity.
- lib/core/theme.dart updated: DividerThemeData configured to remove default 1px solid dividers (thickness: 0, color: transparent) or use tonal alternatives.
- No syntax errors after edits (dart analyzer or successful `flutter analyze` if available).
- midterm-polish-tasks.md line for "The \"No-Line\" Rule" marked as done (- [x]).

Reviewer Findings:
1. **`LumiTextField` Overrides:** `lib/shared/widgets/lumi_text_field.dart` contains an explicit `InputDecoration` that overrides the global theme. It uses `LumiColors.primary.withOpacity(0.4)` for `focusedBorder` instead of the mandated `outline-variant` (Ghost Border).
2. **Explicit 1px Borders Remaining:** Several components still have explicit `1px` borders that violate the "No-Line" rule's intent of removing strokes in favor of tonal shifts or negative space:
    - `lib/widgets/floating_nav_bar.dart`: `Border.all(color: ..., width: 1)` at 8% opacity.
    - `lib/shared/widgets/lumi_buttons.dart`: `LumiSecondaryButton` uses `Border.all(color: ..., width: 1)` (implicit width) at 12% opacity.
    - `lib/features/settings/settings.dart`: `OutlinedButton` styles use `side: BorderSide(color: ..., width: 1)` (implicit width) at 10% opacity.
3. **Ghost Border Color:** The "No-Line" rule specifically mentions using `outline-variant` for the Ghost Border. While `lib/core/theme.dart` was updated, the actual primary input field (`LumiTextField`) is not using it.

Please update these components to remove the explicit 1px borders and ensure `LumiTextField` follows the Ghost Border specification (outline-variant at 40% opacity).

Update (2026-04-12): Implemented fixes:
- `lib/shared/widgets/lumi_text_field.dart`: focusedBorder now uses `LumiColors.outlineVariant.withOpacity(0.4)`.
- `lib/widgets/floating_nav_bar.dart`: removed explicit 1px `Border.all` from BoxDecoration.
- `lib/shared/widgets/lumi_buttons.dart`: removed explicit `Border.all` from `LumiSecondaryButton` decoration.
- `lib/features/settings/settings.dart`: replaced `OutlinedButton.styleFrom(... side: BorderSide(...))` with `side: BorderSide.none` for logout/delete actions.

Verification:
- `dart format` ran successfully on edited files (files formatted). `dart analyze` attempted but failed due to OS file-watch limits; targeted formatting and commits completed.

Next: reviewer should run full `dart analyze` / `flutter analyze` and run visual checks on an Android device to confirm the visual intent.