Task: Verify that background model loading does not block the UI or the test execution.

Planned steps:
1. Inspect existing model registry and FRB wrappers to see how model readiness and progress are exposed.
2. Implement a non-blocking background download stub in rust/lumi_core/src/model_registry.rs that:
   - starts a background thread to simulate download and write a dummy model file;
   - updates shared in-memory progress accessible via get_download_progress.
3. Add FRB-friendly wrapper to start the background download.
4. Add unit tests in rust/lumi_core/src/lib.rs to verify the download starter is non-blocking and progress advances to completion.
5. Run the Rust crate tests to ensure everything passes.
6. Mark the task done in midterm-polish-tasks.md if all verifiable deliverables pass.

Verifiable deliverables:
- File rust/lumi_core/src/model_registry.rs contains a non-blocking start_background_download(...) implementation.
- File rust/lumi_core/src/lib.rs contains a unit test named background_download_non_blocking.
- Running `cargo test --manifest-path rust/lumi_core/Cargo.toml` exits with code 0 (all tests pass).
- File worklog.md exists (this file).

Reviewer Findings:
1. **Test Failure due to Shared State (Race Condition):** 
   Running `cargo test --manifest-path rust/lumi_core/Cargo.toml` fails with exit code 101.
   Specifically, `tests::frb_wrappers_respect_env_model_dir_and_progress_stub` fails because it expects progress to be 0.0, but it gets 0.1 because `background_download_non_blocking` (which runs concurrently) uses the same static `DOWNLOAD_PROGRESS` map and the same model ID ("e2b").
   
   Suggested Fix: Use unique model IDs in different tests (e.g. "test-model-1", "test-model-2") or wrap the tests to ensure they don't interfere with each other's shared state.

2. **Missing Re-export in lib.rs:**
   `frb_start_background_download` is defined in `model_registry.rs` but it's not re-exported in `rust/lumi_core/src/lib.rs`, which is likely required for the FRB bindings to work correctly.
   This results in a "function never used" warning for `frb_start_background_download`.

Actions taken:
1. Implemented unique model IDs per test to avoid shared DOWNLOAD_PROGRESS collisions.
2. Re-exported `frb_start_background_download` in `rust/lumi_core/src/lib.rs`.
3. Ran `cargo test --manifest-path rust/lumi_core/Cargo.toml` — all tests passed (exit code 0).

Verification:
- `cargo test --manifest-path rust/lumi_core/Cargo.toml` exits with code 0 and all tests pass.
- Modified files:
  - `rust/lumi_core/src/lib.rs` (added re-export and updated tests)

Status: Reviewer issues addressed. Ready for re-review.
