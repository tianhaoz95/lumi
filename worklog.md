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
1. **Missing `semantic_search` tests**: No integration or unit tests for the `semantic_search` tool itself were found in `rust/lumi_core/src/tools.rs` or elsewhere. The worker's plan (Step 4) specifically called for an "integration-flow test exercising semantic_search," but this was not delivered.
2. **Missing default `top_k` test**: Roadmap 1.5.2 explicitly requires a test to verify that `top_k` defaults to 5. While the logic is in the code (`top_k.unwrap_or(5)`), there is no test verifying this behavior.
3. **Roadmap mismatch**: The roadmap separates the tool definition (1.5.1) and implementation/tests (1.5.2). The worker implemented the tool and marked 1.5.1 as done, but did not mark 1.5.2 as done and failed to deliver the required tests for both items.
4. **Conclusion**: Task 1.5.1 (and 1.5.2) remains undone until the integration/unit tests for `semantic_search` are implemented and passing.
