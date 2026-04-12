Task: Audit InputDecorationTheme to ensure focused borders use the 40% opacity "Ghost Border" (outline-variant at 40% opacity)

Planned steps:
1. Locate the app theme source (likely lib/core/theme.dart or similar).
2. Inspect current InputDecorationTheme and focusedBorder settings.
3. Modify InputDecorationTheme so focusedBorder (and where appropriate enabled/focused error borders) use a BorderSide color equal to outline-variant (#bec8c9) at 40% opacity (ARGB: 0x66BEC8C9).
4. Ensure no global 1px solid dividers remain for inputs; prefer ghost border or none.
5. Run a quick grep to verify the new color constant or hex literal appears where expected.
6. Run any available Flutter analyzer or relevant tests (if present) to ensure no errors.
7. Update midterm-polish-tasks.md by marking the single task as done (change '- [ ]' to '- [x]') only after verification.

Verifiable deliverables (what reviewers will check):
- worklog.md exists at the repo root and lists the task, steps, and deliverables.
- lib/core/theme.dart contains an InputDecorationTheme where the default `border` and `enabledBorder` use `BorderSide.none`, and `focusedBorder` uses `LumiColors.outlineVariant.withOpacity(0.4)` with width 2.0.
- `errorBorder` and `focusedErrorBorder` are defined and use `colorScheme.error` with reduced opacity (consistent reddish tint while following the ghost-border style).
- No other InputDecorationTheme focusedBorder literal like `Color(0x66BEC8C9)` remains in the codebase (grep should return 0 results for that literal).
- lib/shared/widgets/lumi_text_field.dart no longer defines its own `focusedBorder` (it now inherits the global theme).
- midterm-polish-tasks.md updated: the "Audit InputDecorationTheme" line changed from '- [ ]' to '- [x]'.
- Running `grep -n "LumiColors.outlineVariant.withOpacity(0.4)" -R lib/` should include the theme file, and `grep -n "0x66BEC8C9" -R lib/` should return no results.

## Reviewer Findings
The implementation is incomplete and inconsistent with the project's quality standards.

1. **"No-Line" Violation:** The global `InputDecorationTheme.border` in `lib/core/theme.dart` still has a visible 1px solid border (the default for `OutlineInputBorder`). This violates the "No-Line" rule for the non-focused state. It should be set to `borderSide: BorderSide.none`.
2. **Incomplete Audit:** The audit missed `focusedErrorBorder` and `errorBorder`. These should also be updated to ensure consistency with the "Ghost Border" aesthetic (though they should likely keep a reddish tint, they should still follow the 40% opacity / ghost-border style if that was the intent of the "No-Line" rule for inputs).
3. **Magic Number Usage:** In `lib/core/theme.dart`, the color `0x66BEC8C9` is used as a literal. It should use `LumiColors.outlineVariant.withOpacity(0.4)` to be consistent with other parts of the codebase (like `LumiTextField.dart`) and to ensure semantic maintainability.
4. **Redundant Widget Settings:** `lib/shared/widgets/lumi_text_field.dart` still defines its own `focusedBorder`, which makes the global theme redundant for this specific widget. As part of a thorough audit, these local overrides should be removed if they now match the global theme, or at least unified.

Notes:
- The task in `midterm-polish-tasks.md` has been reverted to `[ ]`.
