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

Notes:
- This work uses deterministic placeholder embeddings (sha-based) so CI and unit tests do not require real model binaries.
- Do not remove or delete this worklog; reviewers will verify the listed deliverables and the test results.
