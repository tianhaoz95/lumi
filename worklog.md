Task: 3.3.2 — Build LanceDB IVF-PQ index on transaction_embeddings after each batch of ≥ 100 new entries

Goal
- Ensure LanceDB creates/updates an IVF-PQ ANN index on transaction_embeddings after batches of 100+ new embeddings to improve RAG search performance.

Planned steps
1. Locate existing LanceDB integration and upsert_embedding implementation in rust/lumi_core.
2. Add a function `build_ivf_pq_index()` that creates or updates the IVF-PQ index for the `transaction_embeddings` collection.
3. Modify the upsert flow to track insert counts and call `build_ivf_pq_index()` when a batch threshold (100) is reached.
4. Add/instrument a small Rust unit/integration test that upserts 100 embeddings and asserts the index-build call completes (returns Ok).
5. Run `cargo test` for the lumi_core crate and fix compilation issues.

Verifiable deliverables
- worklog.md exists (this file).
- File `rust/lumi_core/src/lancedb.rs` (or updated module) contains `build_ivf_pq_index()` implementation.
- `upsert_embedding` calls `build_ivf_pq_index()` after 100 new entries (or a documented counter-based mechanism).
- A Rust test `tests/lancedb_index_build.rs` that upserts 100 embeddings and returns Ok; `cargo test -p lumi_core` passes for that test (or at least builds successfully).
- The Phase 3 roadmap file `design/roadmap/phase-3-snowpack.md` remains unchanged until task completion; after successful verification the task line will be marked done by editing that file.

Notes
- If a full LanceDB server is required at test time, the test will be written to skip when LanceDB is unreachable and still verify code compiles. The reviewer can run the test in an environment with LanceDB available for full verification.