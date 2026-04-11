#!/usr/bin/env bash
set -euo pipefail

# Verifies that lance (LanceDB) dependency is present in the lumi_core Cargo.toml
grep -q "lance =" rust/lumi_core/Cargo.toml && echo "✓ lance dependency found" || (echo "ERROR: lance dependency not found" >&2; exit 2)
