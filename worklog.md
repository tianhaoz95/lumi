Task: Implement Phase 3 task 3.3.1 — Implement vector_search in Rust (LanceDB ANN search)

Planned steps:
1. Locate existing LanceDB integration code (embedding upsert, metadata storage).
2. Add a new function `vector_search(query_vector: Vec<f32>, top_k: u32) -> Result<Vec<SearchResult>>` in the appropriate Rust module (e.g., `rust/lumi_core/src/rag/lancedb.rs`).
3. Implement the search using LanceDB client APIs (ANN query) returning IDs and scores, joined with SQLite for transaction details if needed.
4. Add a unit/integration test that seeds a small set of embeddings and verifies `vector_search` returns expected IDs for a known query vector.
5. Run `cargo test` for the lumi_core crate and fix any compile errors.
6. Document the new function in a short module-level comment.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- New Rust source file or edits containing `vector_search` function present (path: `rust/lumi_core/src/rag/lancedb.rs` or similar).
- A unit or integration test `rag_vector_search` exists and passes: running `cargo test --lib` inside `rust/lumi_core` completes successfully with the test passing.
- README or module comment documents the function signature and behavior.

Notes:
- If existing LanceDB client code is found, extend it; otherwise create a minimal module that depends on the (mockable) LanceDB client so tests can run locally.
- Keep changes confined to the `rust/lumi_core` crate.

Reviewer instructions:
- Verify `cargo test` in `rust/lumi_core` passes and the `rag_vector_search` test asserts expected top-k results.
- Confirm the new function is marked in `design/roadmap/phase-3-snowpack.md` as done when complete.
