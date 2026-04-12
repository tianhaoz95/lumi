Task: 2.1.3 — Verify animation durations

Planned steps:
1. Search the codebase for hardcoded animation durations (e.g., Duration(milliseconds: ...), Duration(seconds: ...)).
2. Identify any durations < 300 ms (except allowed micro-snaps ≤ 150 ms) and any > 500 ms.
3. For each offending occurrence:
   - If it's a micro-snap (intentional small duration for brief UI micro-interaction), annotate with a comment "// micro-snap" and leave as-is.
   - Otherwise, replace hardcoded durations with references to the `LumiAnimations` constants or update the value to fall within [300,500] ms as appropriate.
4. Add a verification script `scripts/check_animation_durations.py` that scans source files for Duration(...) and enforces the rule. The script exits with code 1 if violations are found.
5. Run the verification script locally to ensure zero violations.
6. Update the roadmap file (phase-5-aurora.md) by marking 2.1.3 as done only after verification passes.

Verifiable deliverables:
- File `worklog.md` exists and contains this plan.
- New script `scripts/check_animation_durations.py` is present and executable.
- Running `python3 scripts/check_animation_durations.py` exits with code 0 (no violations).
- All replaced/annotated animation duration occurrences are committed.
- The roadmap line `- [ ] **2.1.3** Verify: no animation duration < 300 ms (except micro-snaps ≤ 150 ms) and none > 500 ms.` is changed to `- [x] ...` after verification.

Notes:
- Do not remove legitimate micro-snap usages (<=150ms); annotate them with `// micro-snap` so the script allows them.
- Use conservative updates: prefer replacing raw numbers with `LumiAnimations` constants if a suitable mapping exists.
