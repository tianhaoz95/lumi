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

---

Reviewer Findings

Summary:
- Cargo tests for `lumi_core` passed (exit 0) but the deliverables in this worklog are not fully satisfied.

Issues found (detailed):

1) embeddings.rs does not export `upsert_embedding` (deliverable mismatch)
- Evidence: `rust/lumi_core/src/embeddings.rs` exists and contains embedding-generation helpers (functions: `embed_transaction`, `embed_transaction_from_summary`, `embed_text`) but does not define or export `upsert_embedding`.
  - File: rust/lumi_core/src/embeddings.rs (contains the embedding helper functions and tests)
- Expectation in worklog: embeddings.rs should export `upsert_embedding`.
- Current reality: the `upsert_embedding` implementation lives in `rust/lumi_core/src/vector_db.rs` (see below).

2) `upsert_embedding` is implemented, but in a different module (vector_db.rs)
- Evidence: `rust/lumi_core/src/vector_db.rs` defines `pub fn upsert_embedding(...)` and `pub fn get_embedding(...)`.
- `lib.rs` re-exports `upsert_embedding` from `vector_db`.
- Impact: The code works (tests passed) but it does not match the requested file/module location in the worklog. The reviewer cannot mark the specific deliverable "embeddings.rs exists and exports upsert_embedding" as done.

3) Missing specific unit test `tests::upsert_embedding_idempotent`
- Evidence: In `vector_db.rs` unit tests there are `upsert_and_get_embedding_roundtrip` and `vector_search_returns_most_similar`, but no test named `upsert_embedding_idempotent` or an explicit idempotency test that calls `upsert_embedding` twice and asserts update (no duplicate).

4) Cargo tests pass but do not exercise the explicit idempotency requirement
- Evidence: `cargo test -p lumi_core` ran and exited 0; it executed existing tests and all passed. However, none of the existing tests assert the two-upsert idempotency semantics requested.

Recommended fixes for the worker:

A) Make the module/export match the worklog OR update the worklog to accept the current layout
- Option 1 (preferred to match worklog): Move (or re-export) `upsert_embedding` into `rust/lumi_core/src/embeddings.rs` and ensure `embeddings.rs` declares `pub fn upsert_embedding(...)` or `pub use crate::vector_db::upsert_embedding;` and add an appropriate module declaration in `lib.rs` if necessary.
- Option 2: Keep implementation in `vector_db.rs` but update the worklog to reflect the actual location (update the deliverable to say `upsert_embedding` is exported from `vector_db.rs` and re-exported in `lib.rs`).

B) Add the idempotency unit test
- Add a test `upsert_embedding_idempotent` (in `vector_db.rs` tests or a dedicated test file) that:
  1. Creates a temp dir and initializes the vector DB (use existing pattern from `upsert_and_get_embedding_roundtrip`).
  2. Calls `upsert_embedding(dir, id, emb1, metadata1)`.
  3. Calls `upsert_embedding(dir, id, emb2, metadata2)` with same id but different embedding/metadata.
  4. Reads the file / record with `get_embedding` and asserts the stored embedding/metadata match the second call (i.e., updated), and that only one file exists for that id (no duplication).
- Run `cargo test -p lumi_core` and ensure the new test passes.

C) Update worklog and roadmap to reflect the intended final layout
- If Option 1 (move/re-export) is chosen, update the code accordingly and then mark worklog as completed and leave `design/roadmap/phase-3-snowpack.md` unchanged.
- If Option 2 is chosen (keep in vector_db.rs), update `worklog.md` to reflect that the implementation lives in `vector_db.rs` and add the idempotent test; then the reviewer can re-check.

Files touched during review (evidence):
- rust/lumi_core/src/embeddings.rs  (contains embed helpers; missing upsert_export)
- rust/lumi_core/src/vector_db.rs  (contains `upsert_embedding`, `get_embedding`, tests)
- rust/lumi_core/src/lib.rs        (re-exports `upsert_embedding` from `vector_db` according to search results)

Next steps required from worker to resolve:
1. Choose Option 1 or Option 2 above.
2. Implement the chosen change and add the `upsert_embedding_idempotent` unit test.
3. Run `cargo test -p lumi_core` and paste results into this worklog (or update the worklog to state tests passed).
4. If Option 1 was chosen, move/re-export function from `vector_db.rs` into `embeddings.rs` and ensure `lib.rs` exports from `embeddings` (or re-exporting is updated appropriately).

Once these changes are made and tests demonstrate the idempotent behavior, notify reviewer by updating this worklog (or removing it if fully satisfied).

Reviewer: Automated code-review agent
Date: 2026-04-11

- Unit test `tests::upsert_embedding_idempotent` present and passes: first insert retrievable, second call updates (no duplicate).
- Running `cargo test -p lumi_core` exits 0 for the new tests.

Notes
- This work focuses only on 3.2.1. Wiring `log_transaction` to call this is task 3.2.2 and will be done separately.
- Do not remove or modify `worklog.md` (reviewer will keep it).

---

Worker actions (2026-04-11T22:29:46Z):

- Chosen Option 1: re-export `upsert_embedding` from `embeddings.rs` to match worklog deliverable.
- Changes made:
  1. Added `pub use crate::vector_db::upsert_embedding;` to `rust/lumi_core/src/embeddings.rs` so the module exports the symbol as requested.
  2. Added a new unit test `upsert_embedding_idempotent` in `rust/lumi_core/src/vector_db.rs` which:
     - Initializes a temp vector DB, calls `upsert_embedding` twice with the same id but different embedding/metadata, and asserts the stored record reflects the second call and that the file for the id exists (no duplicate files).
  3. Ran `cargo test -p lumi_core` successfully.

- Test summary (selected lines):
  - "running 49 tests"
  - "test result: ok. 49 passed; 0 failed; 0 ignored; finished in 0.17s"
  - All lumi_core tests pass locally.

Verifiable deliverables (now satisfied):
- File `rust/lumi_core/src/embeddings.rs` exports `upsert_embedding` (via `pub use crate::vector_db::upsert_embedding;`).
- `rust/lumi_core/src/vector_db.rs` contains `upsert_embedding_idempotent` unit test that passes.
- Running `cargo test -p lumi_core` exits 0 (all tests pass).

Next steps for reviewer: Please verify the three deliverables above and re-run the eval if needed.

Worker: Autonomous coding agent
Date: 2026-04-11T22:29:46Z