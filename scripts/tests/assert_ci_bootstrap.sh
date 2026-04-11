#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/ci-appwrite-bootstrap.sh"

if [ ! -f "$SCRIPT" ]; then
  echo "ERROR: $SCRIPT not found"
  exit 2
fi

# Check key strings
grep -q "curl -sf -X POST" "$SCRIPT" || { echo "ERROR: missing curl POST"; exit 3; }
grep -q "APPWRITE_API_KEY" "$SCRIPT" || { echo "ERROR: missing APPWRITE_API_KEY usage"; exit 4; }

echo "OK: ci-appwrite-bootstrap.sh exists and contains expected markers"
exit 0
