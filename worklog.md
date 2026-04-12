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

Notes:
- Changes scoped to theme.dart and minimal targeted edits elsewhere if explicit Dividers are present.
- Do not delete worklog.md; reviewer will verify outputs.
