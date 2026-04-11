#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPT_FILE="$ROOT_DIR/rust/lumi_core/src/prompts/receipt_ocr.txt"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "MISSING: $PROMPT_FILE"
  exit 2
fi

content=$(cat "$PROMPT_FILE")

echo "Checking prompt contents..."
# Required phrases
required=("You are a receipt parser" "Respond only in valid JSON" "vendor_name" "total_amount" "date")

for r in "${required[@]}"; do
  if ! echo "$content" | grep -Fq "$r"; then
    echo "MISSING PHRASE: $r"
    exit 3
  fi
done

echo "OK: receipt_ocr.txt contains required phrases"
exit 0
