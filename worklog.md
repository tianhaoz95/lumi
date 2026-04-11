Task: 3.1.3 — Backfill embeddings: on first run after upgrade, embed all existing transactions and insert into LanceDB.

Planned steps:
1. Inspect existing embedding helpers at rust/lumi_core/src/embeddings.rs and transaction accessors in rust/lumi_core/src/tools.rs to reuse existing code.
2. Implement a small CLI binary at rust/lumi_core/src/bin/backfill_embeddings.rs that:
   - Initializes the Rust core (DB connections, Lance client if available).
   - Reads all transactions from SQLite (via existing query functions or sea-orm entities).
   - For each transaction, call embed_transaction_from_summary() and upsert into LanceDB (using existing upsert helper if present, else stub to log).
   - Print a final summary: total transactions scanned, embeddings inserted/updated, and any failures.
3. Add a basic integration test or run step to exercise embed_text() returning vector length 768.
4. Run cargo build and run the backfill binary locally to verify it compiles and prints a summary.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- File `rust/lumi_core/src/bin/backfill_embeddings.rs` exists and compiles via `cargo build`.
- `cargo test --lib` (or `cargo test -p lumi_core`) runs the existing embedding unit tests; specifically `embed_text("coffee shop")` unit test passes and returns a vector of length 768.
- Running the backfill binary (`cargo run -p lumi_core --bin backfill_embeddings`) exits successfully and prints a summary line: `Embedded N transactions` (N >= 0).

Notes:
- If LanceDB upsert helper is not yet implemented, the binary will still run and print embeddings-count while logging that LanceDB upsert is a noop; this will still satisfy the deliverable that the backfill compiled and ran. The roadmap later requires implementing upsert_embedding (3.2.1); that will be addressed in its own task.
