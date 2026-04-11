Task: Implement semantic_search tool (phase-3, item 1.5.1)

Planned steps:
1. Add an embed_text(text: &str) helper that produces deterministic placeholder embeddings (768-d) so tests run without model dependencies.
2. Implement vector_search(db_path, query_vector, top_k) in the on-disk vector DB (transaction_embeddings) using cosine similarity.
3. Add a Rig-exposed tool `semantic_search(query: String, top_k: Option<u32>)` in `rust/lumi_core/src/tools.rs` that:
   - embeds the query via embed_text,
   - queries the vector DB for top-k matches,
   - looks up matching transaction rows in SQLite and returns TransactionSummary list.
4. Add unit tests for embed_text, vector_search, and an integration-flow test exercising semantic_search via in-process call.
5. Run `cargo test` for the lumi_core crate and fix any compile/test issues.
6. Mark the roadmap task 1.5.1 as done when all tests pass.

Verifiable deliverables:
- File `rust/lumi_core/src/embeddings.rs` contains function `embed_text(&str) -> Result<Vec<f32>>`.
- File `rust/lumi_core/src/vector_db.rs` contains function `vector_search(db_path: &str, query_vector: &[f32], top_k: u32) -> Result<Vec<(String, f32, String)>, Box<dyn Error>>`.
- File `rust/lumi_core/src/tools.rs` contains a Rig tool `semantic_search(query: String, top_k: Option<u32>) -> anyhow::Result<Vec<TransactionSummary>>`.
- Running `cd rust/lumi_core && cargo test --lib` exits with code 0 (all tests pass).
- `design/roadmap/phase-3-snowpack.md` line for 1.5.1 is updated from `- [ ]` to `- [x]`.

Reviewer Findings:
1. **Flaky tests (Parallel Execution Failure)**: Running `cargo test --lib` in `rust/lumi_core` fails when executed in parallel (the default behavior). Specifically, `log_transaction_tool_wrapper_inserts_row`, `semantic_search_returns_seeded_transaction`, and `semantic_search_respects_default_top_k` fail with database connection errors (`code: 14`) or "embedding not found" errors. This is caused by a race condition where multiple tests concurrently modify and restore the same global environment variables (`LUMI_DB_URL`, `LUMI_VECTOR_DB_PATH`) and cleanup temp directories.
2. **Missing robust test isolation**: To satisfy the deliverable of a clean `cargo test` run, these tests must be made thread-safe (e.g., by not relying on global environment variables or using a serial test runner attribute if available) or the code should be refactored to allow passing DB handles/paths directly to the tools during testing.
3. **Status of 1.5.2**: While the worker has implemented the logic and tests for `semantic_search` (which covers 1.5.2), the tests are currently failing in a standard run. Task 1.5.1 was marked done, but the verification criterion "cargo test --lib exits with code 0" is not met.
4. **Conclusion**: Task 1.5.1 is reverted to incomplete until the test suite is stabilized and passing in parallel.
