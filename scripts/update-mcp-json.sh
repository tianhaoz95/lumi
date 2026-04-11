#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [--from-env] [--api-key KEY]

Options:
  --from-env      Read APPWRITE_API_KEY from .env.test in repo root
  --api-key KEY   Provide the API key directly
EOF
  exit 2
}

API_KEY=""
FROM_ENV=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-env) FROM_ENV=1; shift ;;
    --api-key) API_KEY="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

if [[ $FROM_ENV -eq 1 ]]; then
  if [[ ! -f .env.test ]]; then
    echo ".env.test not found in repo root" >&2
    exit 1
  fi
  # shellcheck disable=SC1091
  # .env.test is simple KEY=VALUE lines; source is acceptable here for controlled dev environment
  set -a
  # shellcheck disable=SC1090
  source .env.test
  set +a
  API_KEY="${APPWRITE_API_KEY:-}"
fi

if [[ -z "$API_KEY" ]]; then
  echo "No API key provided. Use --from-env or --api-key" >&2
  usage
fi

TEMPLATE_PATH=".vscode/mcp.json.template"
OUT_PATH=".vscode/mcp.json"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "Template $TEMPLATE_PATH not found" >&2
  exit 1
fi

mkdir -p .vscode
# Replace placeholder
# Use sed with delimiter that won't conflict
sed "s|<replace-after-bootstrap>|$API_KEY|g" "$TEMPLATE_PATH" > "$OUT_PATH"

echo "Wrote $OUT_PATH"
