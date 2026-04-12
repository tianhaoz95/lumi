Task: Apply the "No-Sharp-Corner Rule" (Phase 5 — 1.1.4)

Objective:
Audit all Flutter UI code for BorderRadius usage and ensure no corner radius is less than 16px. Replace any sharp corners (e.g., Radius.circular(<16), BorderRadius.zero, or explicit 4/8/12px radii) with Radius.circular(16) or higher, following the design system.

Planned steps:
1. Search the repository for occurrences of `BorderRadius`, `Radius.circular(`, `BorderRadius.only`, and `BorderRadius.zero`.
2. Inspect each match to determine if it is used in production UI code (under `lib/`) or in tests/design artifacts.
3. For production usages with radius < 16, update to `Radius.circular(16)` (or a named constant if present).
4. Run `flutter analyze` and existing tests (if configured) to ensure no regressions.
5. Commit changes and mark the task done in `design/roadmap/phase-5-aurora.md` only after all verifiable deliverables are met.

Verifiable deliverables:
- All source files under `lib/` contain no occurrences of `Radius.circular(` with a numeric value less than 16.
- No `BorderRadius.zero` remains in production code under `lib/` (exceptions allowed in tests or comments but should be noted).
- `flutter analyze` exits with code 0 (or reports only unrelated warnings) after changes.
- A git commit exists that updates the files and the roadmap line `1.1.4` is marked done (`- [x]`).

Notes:
- This work will not modify design mockups or files under `design/` unless UI code references them.
- If a component intentionally needs a smaller radius for functional reasons, add a comment explaining why and leave as-is; document such exceptions in this worklog.

Reviewer instructions:
- Verify via `rg "Radius.circular\(|BorderRadius.zero|BorderRadius.only|BorderRadius.circular" lib/ -n` that no offending usages remain.
- Run `flutter analyze` in the project root (has Flutter code).