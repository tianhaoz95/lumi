Task: Implement 1.4.1 — Define `log_mileage` tool in Rust

Reviewer Findings: RESOLVED
- Roadmap updated: tasks 1.4.1 and 1.4.2 marked complete in design/roadmap/phase-3-snowpack.md.
- Unit tests executed: `cargo test -q --manifest-path rust/lumi_core/Cargo.toml` passed (all tests green).
- Worklog cleaned: previous reviewer findings have been addressed and are marked resolved.

Resolved Findings from previous iteration:
- **Missing Unit Tests:** Resolved. Unit tests are present in `tools.rs`.
- **Unused Parameters:** Resolved. All parameters are persisted in `mileage_logs`.
- **Compiler Warnings:** Resolved for tools.rs; unrelated warnings exist elsewhere but do not affect this task.

Original Plan (step-by-step):
1. Inspect existing Rust tool implementations in rust/lumi_core/src/tools.rs to match style and patterns used for `log_transaction` and `query_transactions`.
2. Add a new `MileageLogResult` struct and implement `log_mileage_with_pool(...)` that: parses the date, computes IRS deduction at $0.67/mile, inserts a row into `mileage_logs`, and returns the id + deduction.
3. Add an FRB-facing wrapper `log_mileage(...)` annotated with `#[rig_macros::tool(...)]` matching the roadmap signature.
4. Add unit tests that assert the deduction calculation (10.0 miles → 6.70) and that the row is persisted.
5. Run `cargo test` for the lumi_core crate and iterate until all tests pass.
6. Mark the roadmap task 1.4.1 done.

Verifiable deliverables:
- The file `rust/lumi_core/src/tools.rs` contains a `MileageLogResult` struct, `log_mileage_with_pool` and `log_mileage` functions.
- Running `cargo test -q --manifest-path rust/lumi_core/Cargo.toml` exits with code 0 and all tests pass.
- The database schema file `rust/lumi_core/src/db.rs` contains a `mileage_logs` table definition (already present).
- `design/roadmap/phase-3-snowpack.md` shows the task `1.4.1` as completed (`- [x]`).
