# GEMINI.md - Project Lumi

## Project Overview
**Lumi** (Finnish for *Snow*) is an agentic, local-first financial companion designed for 2026. It focuses on "Zero-Entry" bookkeeping, using multimodal LLMs to automate financial tracking with a privacy-first, on-device approach.

### Core Philosophy
- **Privacy-First:** 100% on-device processing for PII.
- **Intelligence-First:** Multimodal LLMs for receipt parsing and financial reasoning.
- **Proactive:** A "Sentinel" system that monitors records and prompts for missing data.

### Technical Stack ("Glacier" Architecture)
- **Frontend:** Flutter 3.x (Impeller), Riverpod (State Management), GoRouter (Routing).
- **Bridge:** `flutter_rust_bridge` (FRB v2) for high-performance Dart/Rust communication.
- **Orchestrator:** **Rig (Rust)** for agent memory, tool-calling, and RAG.
- **Inference:** LiteRT-LM (NPU-accelerated) running Gemma 4 models (E2B for background, E4B for foreground).
- **Storage:** SQLite (Relational) + LanceDB (Vector/RAG).
- **Backend (Dev/Sync):** Appwrite (used primarily for integration tests and potential cloud sync).

---

## Building and Running

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Rust Toolchain
- Docker (for local Appwrite services)
- `flutter_rust_bridge_codegen` (Install via `cargo install flutter_rust_bridge_codegen --version 2.11.1`)
- `uv` (for Appwrite MCP server, see `README.md`)

### Key Commands
Commands are managed via the root `Makefile`:

| Command | Description |
| :--- | :--- |
| `make setup` | Install Flutter dependencies and check for Rust toolchain. |
| `make codegen` | Generate Dart bindings from Rust code using FRB. |
| `make run` | Run the Flutter application. |
| `make test` | Run both Rust and Flutter unit tests. |
| `make services-up` | Start local Appwrite services using Docker Compose. |
| `make services-down` | Stop local Appwrite services. |
| `make test-integration` | Run Flutter integration tests (requires `.env.test`). |
| `make appwrite-reset` | Reset Appwrite volumes and restart services. |

---

## Development Conventions

### Architecture & Directory Structure
- **`lib/`**: Flutter frontend code.
  - `core/`: App initialization, routing, and themes.
  - `features/`: Feature-based modules (auth, dashboard, settings, etc.).
  - `shared/`: Reusable widgets and the Rust bridge (`shared/bridge/`).
- **`rust/`**: Rust core logic (`lumi_core`).
  - `src/lib.rs`: Main entry point for FRB bindings.
- **`design/`**: Project specifications, PRD, and implementation roadmaps.
- **`scripts/`**: Automation scripts for environment setup and Appwrite bootstrapping.
- **`integration_test/`**: End-to-end tests for core workflows.

### Coding Standards
- **Dart:** Follow standard Flutter linting (defined in `analysis_options.yaml`). Use Riverpod for state management.
- **Rust:** Use `lumi_core` for heavy logic, AI orchestration, and database access. Ensure FRB compatibility.
- **State Management:** Riverpod is the preferred solution.
- **Routing:** Use GoRouter as defined in `lib/core/router.dart`.

### Testing Practices
- **Unit Tests:** Located in `test/` (Flutter) and `rust/lumi_core/src/` (Rust). Run via `make test`.
- **Integration Tests:** Located in `integration_test/`. These require a running Appwrite instance and a valid `.env.test` file (generated via the bootstrap process in `scripts/BOOTSTRAP.md`).

---

## Local Appwrite Testing Service Setup

Integration tests require a locally running Appwrite instance. Follow these steps to set it up:

1. **Start Services:**
   ```bash
   make services-up
   # Wait for Appwrite to be healthy
   ./scripts/wait-for-appwrite.sh
   ```

2. **Install Appwrite CLI:**
   ```bash
   npm install -g appwrite-cli
   ```

3. **Login to Console:**
   The first user created in a fresh Appwrite install becomes the admin.
   ```bash
   appwrite client --endpoint http://localhost/v1
   appwrite login --email admin@lumi.test --password AdminPassword123
   ```

4. **Bootstrap Test Project:**
   ```bash
   # Create a team for the project
   appwrite client --project-id console
   appwrite teams create --team-id lumi-team --name "Lumi Team"

   # Create the project
   appwrite projects create --project-id lumi-test --name "Lumi Test" --team-id lumi-team

   # Create an API Key with all scopes
   appwrite projects create-key --project-id lumi-test --name "Lumi Test Key" --scopes sessions.write users.read users.write teams.read teams.write databases.read databases.write collections.read collections.write attributes.read attributes.write indexes.read indexes.write documents.read documents.write files.read files.write buckets.read buckets.write functions.read functions.write execution.read execution.write locale.read avatars.read health.read providers.read providers.write messages.read messages.write topics.read topics.write subscribers.read subscribers.write targets.read targets.write rules.read rules.write migrations.read migrations.write vcs.read vcs.write assistant.read --show-secrets
   ```

5. **Configure `.env.test`:**
   Update `.env.test` with the `APPWRITE_API_KEY` obtained from the previous step. 
   **Note:** For physical Android devices, use your local machine's IP (e.g., `192.168.x.x`) instead of `localhost` in `APPWRITE_ENDPOINT`.

6. **Create Test Users:**
   ```bash
   appwrite client --project-id lumi-test
   appwrite users create --user-id "test-user" --email test@lumi.com --password TestPass123! --name "Test User"
   appwrite users create --user-id "reset-user" --email reset@lumi.com --password TestPass123! --name "Reset User"
   ```

---

## Running Integration Tests

Integration tests require a valid `.env.test` file and a running Appwrite service (see setup above).

Lumi integration tests prefer physical Android devices over the Linux host to ensure compatibility with on-device acceleration (Phase 2+).

### Preferred: Physical Android Device
1. Find your device ID:
   ```bash
   flutter devices
   ```
2. Run all integration tests:
   ```bash
   make test-integration DEVICE=<DEVICE_ID>
   ```

### Fallback: Desktop (Linux)
If no physical device is connected, you can run tests on the Linux host:
```bash
make test-integration DEVICE=linux
```

---

## Roadmap Phases
1. **Phase 1: Permafrost** - Foundation, Flutter + Rust Bridge, SQLite/LanceDB setup.
2. **Phase 2: Thaw** - On-device inference with LiteRT-LM and Gemma 4.
3. **Phase 3: Snowpack** - Agentic orchestration with Rig and local RAG.
4. **Phase 4: Sentinel** - Proactive background monitoring and geofencing.
5. **Phase 5: Aurora** - UX Polish, "Cozy Cabin" theme, and audit reports.

---
*Last updated: April 10, 2026*
