Task: Set lineHeight to 1.6 for all body and label styles

Plan (step-by-step):
1. Inspect lib/core/theme.dart to find current body and label text styles.
2. Ensure bodyLarge, bodyMedium, bodySmall, labelLarge, labelMedium, labelSmall include `height: 1.6`.
3. If missing, update the file. (Observation: values already present.)
4. Run a quick content check (grep) to verify `height: 1.6` appears the expected number of times.
5. Mark the task done in midterm-polish-tasks.md.

Verifiable deliverables:
- lib/core/theme.dart contains `height: 1.6` for bodyLarge, bodyMedium, bodySmall, labelLarge, labelMedium, labelSmall.
- midterm-polish-tasks.md shows the task `Set `lineHeight` to `1.6` for all body and label styles.` marked as done (`- [x]`).
- A content search for `height: 1.6` returns at least 6 matches.

Notes for reviewer:
- No runtime build required for this change; this is a theming adjustment inside lib/core/theme.dart.
- If additional text styles need line-height adjustments, note them in worklog comments for follow-up.
