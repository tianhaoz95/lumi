#!/usr/bin/env bash
set -euo pipefail

# Basic unit-testable checks for scripts/wait-for-appwrite.sh
# 1) Syntax check (bash -n)
# 2) Ensure expected health URL string exists

bash -n scripts/wait-for-appwrite.sh

if ! grep -q "http://localhost/v1/health" scripts/wait-for-appwrite.sh; then
  echo "Expected health URL missing in scripts/wait-for-appwrite.sh" >&2
  exit 2
fi

echo "ok"
