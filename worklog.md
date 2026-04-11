Task: Define the `get_summary` tool (phase-3, task 1.6.1)

Planned steps:
1. Add a `FinancialSummary` struct to `rust/lumi_core/src/tools.rs`.
2. Implement an FRB-exposed tool `get_summary(period: String) -> Result<FinancialSummary>` in `tools.rs` that computes totals for a time period (this_month, last_month, ytd).
3. Export `get_summary` from `rust/lumi_core/src/lib.rs` so FRB bindings can use it.
4. Run `cargo test` in `rust/lumi_core` (compile + unit tests) to ensure no regressions.

Verifiable deliverables:
- File `rust/lumi_core/src/tools.rs` contains a `FinancialSummary` struct and an async `get_summary` function annotated with `#[rig_macros::tool(...)]`.
- `rust/lumi_core/src/lib.rs` re-exports `get_summary`.
- `cargo test` in `rust/lumi_core` completes successfully (exit code 0) for the unit tests.
- `worklog.md` exists at repo root and lists the above plan and deliverables.

Notes:
- Implementation focuses on accurate SQL aggregation for expenses and mileage; working hours is left as `None` until a dedicated table exists.
