# lumi

## Development Setup

This project uses the Appwrite MCP server workflow (Copilot agent-based bootstrapping) for one-time development setup of Appwrite resources used in integration tests.

Follow these steps once per development machine:

1. Install the `uv` runner used by the Appwrite MCP server:

   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. Create a local MCP config copy (do not commit secrets):

   ```bash
   # Copy the template and edit the API key afterwards
   cp .vscode/mcp.json.template .vscode/mcp.json
   # Edit .vscode/mcp.json and replace <replace-after-bootstrap> with the API key returned by the bootstrap step
   ```

   Note: `.vscode/mcp.json` is git-ignored by default. Do not commit it.

3. Start the local Appwrite services (Docker Compose):

   ```bash
   docker compose -f docker-compose.appwrite.yml up -d
   bash scripts/wait-for-appwrite.sh
   ```

4. Open your editor's Copilot agent mode and run the bootstrap prompt found in `scripts/BOOTSTRAP.md` (this will create the `lumi-test` project, API key, test users, and write `.env.test`). After the bootstrap completes, copy the generated API key into `.vscode/mcp.json`.

5. Verify the environment:

   ```bash
   # Ensure Appwrite project reachable
   curl -sf http://localhost/v1/projects/lumi-test

   # Ensure .env.test was written
   test -f .env.test && echo ".env.test exists"
   ```

If you prefer CI-only setup, see `scripts/ci-appwrite-bootstrap.sh` for the REST-based bootstrap used in CI.

---

(Developer notes: this section satisfies the one-time MCP setup documentation required by the Phase 1 roadmap.)
