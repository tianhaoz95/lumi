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
- lib/core/theme.dart (or the theme file modified) contains an InputDecorationTheme with focusedBorder using Color(0x66BEC8C9) (outline-variant at 40% opacity).
- No other InputDecorationTheme focusedBorder entries override this (grep should show only the intended change).
- midterm-polish-tasks.md updated: the "Audit InputDecorationTheme" line changed from '- [ ]' to '- [x]'.
- Running `grep -n "0x66BEC8C9" -R lib/` returns the modified theme file.

Notes:
- Do not delete worklog.md after completion. Leave it for reviewer.
- If theme file is in a different path, update that file instead and list its path in the worklog.
