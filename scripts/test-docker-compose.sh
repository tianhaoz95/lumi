#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/docker-compose.appwrite.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "MISSING: $COMPOSE_FILE"
  exit 2
fi

# Check required services
if ! grep -E '^\s*appwrite:' -q "$COMPOSE_FILE"; then
  echo "Missing 'appwrite' service in $COMPOSE_FILE"
  exit 3
fi
if ! grep -E '^\s*mariadb:' -q "$COMPOSE_FILE"; then
  echo "Missing 'mariadb' service in $COMPOSE_FILE"
  exit 4
fi
if ! grep -E '^\s*redis:' -q "$COMPOSE_FILE"; then
  echo "Missing 'redis' service in $COMPOSE_FILE"
  exit 5
fi
if ! grep -q 'mailhog' "$COMPOSE_FILE"; then
  echo "Missing 'mailhog' service in $COMPOSE_FILE"
  exit 6
fi

# Optional port checks (warn but do not fail)
if ! grep -q '80:80' "$COMPOSE_FILE"; then
  echo "Warning: port mapping 80:80 not found"
fi
if ! grep -q '8025:8025' "$COMPOSE_FILE"; then
  echo "Warning: port mapping 8025:8025 not found"
fi
if ! grep -q '1025:1025' "$COMPOSE_FILE"; then
  echo "Warning: port mapping 1025:1025 not found"
fi

echo "docker-compose.appwrite.yml contains required services."
exit 0
