#!/usr/bin/env bash
set -euo pipefail
DOC="design/models.md"
if [ ! -f "$DOC" ]; then
  echo "ERROR: $DOC missing"
  exit 2
fi
# Check for Gemma entries and SHA placeholder or hex-like string
grep -q "Gemma 4 E2B" "$DOC" || { echo "ERROR: Gemma 4 E2B entry missing"; exit 3; }
grep -q "Gemma 4 E4B" "$DOC" || { echo "ERROR: Gemma 4 E4B entry missing"; exit 4; }
# Ensure there is a sha256 line for each model (placeholder accepted)
grep -q "sha256: REPLACE_WITH_REAL_SHA256_HEX_FOR_GEMMA_4_E2B" "$DOC" || grep -qE "sha256: [0-9a-fA-F]{64}" "$DOC" || { echo "WARNING: E2B sha256 missing or malformed"; exit 5; }
grep -q "sha256: REPLACE_WITH_REAL_SHA256_HEX_FOR_GEMMA_4_E4B" "$DOC" || grep -qE "sha256: [0-9a-fA-F]{64}" "$DOC" || { echo "WARNING: E4B sha256 missing or malformed"; exit 6; }

echo "OK: design/models.md presence and basic sanity checks passed"
