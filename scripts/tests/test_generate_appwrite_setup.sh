#!/usr/bin/env bash
set -euo pipefail

# Run the generator
bash ../generate_appwrite_setup.sh

# Check files
if [[ ! -f .vscode/mcp.json.template ]]; then
  echo "FAIL: .vscode/mcp.json.template not created"
  exit 2
fi
if ! grep -q 'lumi-dev' .vscode/mcp.json.template; then
  echo "FAIL: .vscode/mcp.json.template does not contain lumi-dev"
  exit 3
fi
if [[ ! -f .env.test.template ]]; then
  echo "FAIL: .env.test.template not created"
  exit 4
fi
if ! grep -q 'APPWRITE_PROJECT_ID=lumi-dev' .env.test.template; then
  echo "FAIL: .env.test.template missing project id"
  exit 5
fi

echo "OK: generated templates present"
