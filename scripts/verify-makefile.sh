#!/usr/bin/env bash
set -euo pipefail

# Verify Makefile exists and contains expected targets
if [ ! -f Makefile ]; then
  echo "Makefile missing" >&2
  exit 2
fi

missing=0
for target in codegen test-unit test-integration services-up; do
  if ! grep -q "^${target}:" Makefile; then
    echo "Missing target: ${target}" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  echo "Makefile verification failed" >&2
  exit 3
fi

echo "Makefile verification passed"
exit 0
