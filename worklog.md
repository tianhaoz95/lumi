Task: Implement get_summary (Phase 3 — 1.6.2)

Planned steps:
1. Add unit tests for `get_summary` covering:
   - `this_month` returns correct totals for seeded transactions and mileage.
   - unknown period returns an error.
2. Run the Rust unit tests (cargo test) to validate behavior.
3. Mark the roadmap task as done once tests pass.

Verifiable deliverables:
- File `worklog.md` exists at repository root and lists the task, plan, and deliverables.
- New tests in `rust/lumi_core/src/tools.rs`:
  - `get_summary_this_month_returns_correct_totals`
  - `get_summary_unknown_period_returns_error`
- Running `cargo test -p lumi_core` (or `cargo test` in rust/lumi_core) succeeds for the new tests.
- The roadmap file `design/roadmap/phase-3-snowpack.md` is updated: the line for **1.6.2** is checked (`- [x]`).
