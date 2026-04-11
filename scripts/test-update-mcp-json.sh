#!/usr/bin/env bash
set -euo pipefail

# Test runner for scripts/update-mcp-json.sh
REPO_ROOT="/home/tianhaoz/github/lumi"
cd "$REPO_ROOT"

# Backup existing files if present
bak_mcp=0
bak_template=0
if [[ -f .vscode/mcp.json ]]; then
  mv .vscode/mcp.json .vscode/mcp.json.bak
  bak_mcp=1
fi
if [[ -f .vscode/mcp.json.template ]]; then
  mv .vscode/mcp.json.template .vscode/mcp.json.template.bak
  bak_template=1
fi

cleanup() {
  set +e
  # restore backups
  if [[ $bak_mcp -eq 1 ]]; then
    mv .vscode/mcp.json.bak .vscode/mcp.json
  else
    rm -f .vscode/mcp.json
  fi
  if [[ $bak_template -eq 1 ]]; then
    mv .vscode/mcp.json.template.bak .vscode/mcp.json.template
  else
    rm -f .vscode/mcp.json.template
  fi
  rm -f .env.test
}
trap cleanup EXIT

# Create a minimal .env.test
cat > .env.test <<EOF
APPWRITE_API_KEY=TESTKEY1234567890
EOF

# Create a minimal template
mkdir -p .vscode
cat > .vscode/mcp.json.template <<'EOF'
{
  "servers": {
    "appwrite": {
      "command": "uvx",
      "args": ["mcp-server-appwrite"],
      "env": {
        "APPWRITE_ENDPOINT": "http://localhost/v1",
        "APPWRITE_PROJECT_ID": "lumi-test",
        "APPWRITE_API_KEY": "<replace-after-bootstrap>"
      }
    }
  }
}
EOF

# Run the update script
bash scripts/update-mcp-json.sh --from-env

# Assert the API key was substituted
if grep -q "TESTKEY1234567890" .vscode/mcp.json; then
  echo "TEST OK: API key present in .vscode/mcp.json"
else
  echo "TEST FAILED: API key not found in .vscode/mcp.json" >&2
  exit 1
fi
