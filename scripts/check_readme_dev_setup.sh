#!/usr/bin/env bash
set -euo pipefail

README="$(dirname "$0")/.."/README.md

if ! grep -q "Development Setup" "$README"; then
  echo "ERROR: README missing 'Development Setup' heading"
  exit 2
fi

if ! grep -q "Install the `uv` runner" "$README" && ! grep -q "curl -LsSf https://astral.sh/uv/install.sh" "$README"; then
  echo "ERROR: README missing uv install command"
  exit 3
fi

if ! grep -q "cp .vscode/mcp.json.template .vscode/mcp.json" "$README"; then
  echo "ERROR: README missing mcp.json template instructions"
  exit 4
fi

echo "README Development Setup section verified"
