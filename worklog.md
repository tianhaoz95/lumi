Task: Implement 3.1.1 — `embed_text(text: String) -> Result<Vec<f32>>` using the E2B model embedding output (dimension: 768).

Planned steps:
1. Inspect existing embeddings implementation in `rust/lumi_core/src/embeddings.rs`.
2. If a placeholder implementation exists, keep it but verify its behaviour matches the API (returns Vec<f32> length 768, deterministic).
3. Run the Rust unit tests for the lumi_core crate to ensure embedding tests pass.
4. If tests fail, fix implementation and re-run until passing.
5. Mark the roadmap task as done in `design/roadmap/phase-3-snowpack.md` once all deliverables are satisfied.

Verifiable deliverables:
- worklog.md file exists at repository root and documents the task and plan.
- `rust/lumi_core/src/embeddings.rs` contains a public `embed_text(text: &str) -> Result<Vec<f32>>` function.
- Calling `embed_text("coffee shop")` returns a Vec<f32> of length 768.
- `cargo test` for the lumi_core crate passes (embedding-related unit tests succeed).

Notes:
- This work uses the existing deterministic placeholder embedding until LiteRT-LM embedding bindings are available. The placeholder is deterministic and suitable for unit tests.
