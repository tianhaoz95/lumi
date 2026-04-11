Task: Implement Phase 3 ▸ 3.2.1 — upsert_embedding

Objective
- Implement `upsert_embedding(id: String, vector: Vec<f32>, metadata: String)` in Rust to insert or update transaction embeddings in LanceDB's `transaction_embeddings` collection.

Planned steps
1. Search the Rust core for existing embedding/LanceDB code and tests.
2. Add a new module (rust/lumi_core/src/embeddings.rs) with `upsert_embedding` implementation using the project's LanceDB client wrapper (or add a small wrapper if missing).
3. Add unit tests: upsert succeeds and row retrievable; second upsert updates (no duplicate).
4. Run `cargo test` for lumi_core to validate.
5. If tests pass, record results here and leave worklog for reviewer.

Verifiable deliverables
- File `rust/lumi_core/src/embeddings.rs` exists and exports `upsert_embedding`.
- Unit test `tests::upsert_embedding_idempotent` present and passes: first insert retrievable, second call updates (no duplicate).
- Running `cargo test -p lumi_core` exits 0 for the new tests.

Notes
- This work focuses only on 3.2.1. Wiring `log_transaction` to call this is task 3.2.2 and will be done separately.
- Do not remove or modify `worklog.md` (reviewer will keep it).