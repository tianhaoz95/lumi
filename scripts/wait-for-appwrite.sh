#!/usr/bin/env bash
set -euo pipefail

# Wait until Appwrite health endpoint responds
until curl -sf http://localhost/v1/health > /dev/null; do
  echo "Waiting for Appwrite..."
  sleep 2
done

echo "✓ Appwrite is ready"
