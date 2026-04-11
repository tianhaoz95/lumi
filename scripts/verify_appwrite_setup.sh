#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE="$ROOT_DIR/docker-compose.appwrite.yml"
WAIT_SCRIPT="$ROOT_DIR/scripts/wait-for-appwrite.sh"

if [ ! -f "$COMPOSE" ]; then
  echo "MISSING: $COMPOSE"
  exit 2
fi

# Check for required services
if ! grep -E "appwrite|mariadb|mailhog" -n "$COMPOSE" >/dev/null; then
  echo "docker-compose missing required services (appwrite/mariadb/mailhog)"
  exit 3
fi

if [ ! -f "$WAIT_SCRIPT" ]; then
  echo "MISSING: $WAIT_SCRIPT"
  exit 4
fi

if ! grep -q "curl -sf http://localhost/v1/health" "$WAIT_SCRIPT"; then
  echo "wait script does not contain health check"
  exit 5
fi

echo "OK: Appwrite compose and wait script present"
