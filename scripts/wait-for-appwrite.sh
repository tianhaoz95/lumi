#!/usr/bin/env bash
set -euo pipefail

# Wait until Appwrite health endpoint responds (even if it's a 401/403, it means it's up)
TIMEOUT=600 # 10 minutes
START_TIME=$SECONDS

until curl -s -o /dev/null -w "%{http_code}" http://localhost/v1/health | grep -E "200|401|403" > /dev/null; do
  ELAPSED=$(( SECONDS - START_TIME ))
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "Error: Appwrite failed to become ready within $TIMEOUT seconds."
    exit 1
  fi
  echo "Waiting for Appwrite ($ELAPSED/$TIMEOUT)..."
  sleep 5
done

echo "✓ Appwrite is ready"
