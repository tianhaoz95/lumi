# Model Registry — Lumi

This document lists the canonical model files used by Lumi (Phase 2: Thaw) and their expected SHA-256 hashes. Before distributing or using a model, verify its SHA-256 integrity using the `check_model_ready(model_id)` helper in the Rust ModelRegistry.

Notes:
- Models are large; store under the platform app support directory (external to Flutter assets).
- Replace the placeholder URLs and hashes below with authoritative values provided by the model vendor.

## Gemma 4 E2B (Sentinel)

- id: gemma-4-e2b
- recommended_filename: gemma-4-e2b.task
- example_download_url: https://models.example.com/gemma-4-e2b/task-file
- sha256: REPLACE_WITH_REAL_SHA256_HEX_FOR_GEMMA_4_E2B
- expected_size_bytes: REPLACE_WITH_BYTES

## Gemma 4 E4B (Auditor)

- id: gemma-4-e4b
- recommended_filename: gemma-4-e4b.task
- example_download_url: https://models.example.com/gemma-4-e4b/task-file
- sha256: REPLACE_WITH_REAL_SHA256_HEX_FOR_GEMMA_4_E4B
- expected_size_bytes: REPLACE_WITH_BYTES

## Integrity verification

1. After download, compute the SHA-256 of the file and compare with the listed `sha256` value.
2. The Rust `ModelRegistry::check_model_ready(model_id: String) -> bool` must return `true` only when both size and SHA-256 match the documented values.
3. If the hash does not match, delete the file and re-download from the authoritative URL.

## Change log

- 2026-04-11: Created initial registry with placeholders for Gemma 4 E2B and E4B. Replace placeholders with vendor-provided URLs and hashes.
