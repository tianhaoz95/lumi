# ❄️ Lumi — High-Level Implementation Plan

> **Project Lumi** ("Snow" in Finnish) is a zero-entry, local-first, agentic bookkeeping app. All financial PII remains on-device. A locally hosted **Appwrite** instance handles authentication and user management during development.

---

## Stack Summary

| Layer | Technology | Role |
|---|---|---|
| UI | Flutter 3.x (Impeller) | All screens, animations, GenUI widgets |
| Agentic UI | Flutter AI Toolkit | Chat interface, multimodal input |
| Dynamic Widgets | GenUI SDK | Model-driven TransactionCard, InsightCard |
| Dart↔Rust Bridge | flutter_rust_bridge v2 (FRB v2) | Streaming SSE, async RPC |
| Auth / Dev Backend | Appwrite (self-hosted) | User accounts, session tokens, password reset |
| Agentic Core | Rig (Rust) | Tool-calling, memory, RAG orchestration |
| Local Inference | LiteRT-LM (Rust) | NPU-accelerated inference runtime |
| Models | Gemma 4 E2B + E4B | Sentinel (background) / Auditor (foreground) |
| Relational DB | SQLite via sea-orm (Rust) | Transactions, mileage logs, receipts |
| Vector / RAG DB | LanceDB (Rust) | Embeddings for semantic financial history |

---

## Architecture: "The Glacier"

```
┌──────────────────────────────────────────────────────┐
│                  Flutter (Dart)                      │
│  Screens → Flutter AI Toolkit → GenUI Widgets        │
│              ↕ FRB v2 Bridge (< 2ms)                 │
│                  Rust Core                           │
│   Appwrite SDK ←→ Auth Module                        │
│   Rig Orchestrator → Tools → sea-orm → SQLite        │
│                           → LanceDB (RAG)            │
│   LiteRT-LM Runtime → Gemma E2B / E4B                │
└──────────────────────────────────────────────────────┘
```

**Key constraint:** Only the Appwrite Auth module is allowed to make network calls. All financial data (transactions, receipts, mileage) never leaves the device.

---

## Screen Inventory

| Screen | Design File | Auth Required |
|---|---|---|
| Login | `ui_design/login/` | No |
| Sign Up | `ui_design/sign_up/` | No |
| Forgot Password | `ui_design/forgot_password/` | No |
| Home / Chat ("Lumi AI") | `ui_design/home/` | Yes |
| Dashboard ("The Tundra") | `ui_design/dashboard/` | Yes |
| Settings ("The Cabin") | `ui_design/settings/` | Yes |

---

## Design System at a Glance

- **Palette**: Deep Pine Frost (primary `#00464a`, surface `#f5fafc`)
- **Fonts**: Manrope (headlines, `letter-spacing: -0.02em`) + Inter (body, `line-height: 1.6`)
- **Rules**: No divider lines, no sharp corners (min 16px radius), no pure black. Glassmorphism for floating elements. Animations 300–500 ms ease-out only.
- **Mascot**: Kit the Fox — ghost presence (5–10% opacity) in cards and empty states.

---

## Implementation Phases

| Phase | Name | Theme | Key Deliverable |
|---|---|---|---|
| 1 | Permafrost | Foundation & Bridge | Flutter shell + FRB v2 + Rust scaffold + Appwrite auth + SQLite/LanceDB init |
| 2 | Thaw | On-Device Inference | LiteRT-LM running Gemma 4 E2B/E4B, token streaming to Flutter |
| 3 | Snowpack | Agentic Orchestration | Rig agent with tools, local RAG pipeline functional |
| 4 | Sentinel | Proactive Layer | BackgroundGuard heartbeat + geofence triggers + push notifications |
| 5 | Aurora | UX Polish & Audit | "Cozy Cabin" theme complete, Kit animations, SHA-256 audit trail, PDF export |

Detailed plans for each phase live in `design/roadmap/`:

- [`phase-1-permafrost.md`](roadmap/phase-1-permafrost.md)
- [`phase-2-thaw.md`](roadmap/phase-2-thaw.md)
- [`phase-3-snowpack.md`](roadmap/phase-3-snowpack.md)
- [`phase-4-sentinel.md`](roadmap/phase-4-sentinel.md)
- [`phase-5-aurora.md`](roadmap/phase-5-aurora.md)

---

## Success Criteria (Cross-Phase)

| Metric | Target |
|---|---|
| FRB v2 round-trip latency | < 2 ms |
| Model load time | < 3 s |
| Inference throughput | > 25 tokens/sec on NPU |
| Background heartbeat battery drain | < 4% per day |
| Geofence notification delay | < 60 s after leaving venue |
| RAG retrieval accuracy | ≥ 95% on historical queries |
| UI frame rate | Constant 120 fps (Impeller) |

---

## Appwrite Local Setup

Appwrite is the development auth backend. It must be running locally before starting any auth-related development.

```bash
# Start Appwrite (Docker Compose)
docker compose up -d

# Appwrite console: http://localhost/console
```

**Appwrite resources to create:**
- Project: `lumi-dev`
- Platform: Flutter (bundle ID `com.lumi.app`)
- Auth methods: Email/Password enabled
- SMTP: Configured for password-reset emails in dev

The Flutter app connects to `http://localhost` (or LAN IP for device testing). Credentials are stored only in Appwrite's own encrypted storage; no financial data touches Appwrite.

---

## Testing Automation

This section describes the complete automated integration test pipeline. Integration tests target a locally hosted Appwrite instance that is bootstrapped and torn down programmatically using the **Appwrite MCP server** (`mcp-server-appwrite`).

### Infrastructure: Docker Compose

Create `docker-compose.appwrite.yml` at the project root. It runs:

| Service | Image | Purpose |
|---|---|---|
| `appwrite` | `appwrite/appwrite:latest` | Auth, user management |
| `appwrite-worker-*` | (Appwrite worker images) | Background jobs |
| `mariadb` | `mariadb:10.7` | Appwrite's internal DB |
| `redis` | `redis:7` | Appwrite queue/cache |
| `mailhog` | `mailhog/mailhog` | SMTP sink for password-reset emails |

```bash
# Start all services
docker compose -f docker-compose.appwrite.yml up -d

# Check health
until curl -sf http://localhost/v1/health > /dev/null; do sleep 2; done
echo "Appwrite ready"

# Mailhog web UI (inspect sent emails)
open http://localhost:8025
```

Volumes persist Appwrite state between runs. Use `docker compose ... down -v` to perform a full wipe.

---

### Appwrite MCP Configuration

The Appwrite MCP server is the only tool that should create or modify Appwrite resources during development or CI. Direct REST calls or console edits are discouraged because they cannot be reproduced automatically.

**Install `uv` (one-time):**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**VS Code config** (`.vscode/mcp.json`, add to `.gitignore`):
```json
{
  "servers": {
    "appwrite": {
      "command": "uvx",
      "args": ["mcp-server-appwrite"],
      "env": {
        "APPWRITE_ENDPOINT": "http://localhost/v1",
        "APPWRITE_PROJECT_ID": "lumi-test",
        "APPWRITE_API_KEY": "<generated-during-bootstrap>"
      }
    }
  }
}
```

Activate in Copilot Chat by switching to **Agent Mode** (the `@` selector → `appwrite`).

---

### Bootstrap Sequence (First-Time, Automated via Appwrite MCP)

Ask Copilot in agent mode:

> **"Using the appwrite MCP server, fully initialise the lumi-test project for integration testing following the bootstrap sequence in IMPLEMENTATION_PLAN.md."**

Copilot will call `appwrite_call_tool` for each step:

| Step | MCP action | Expected result |
|---|---|---|
| 1 | Create project `lumi-test` | Project ID confirmed as `lumi-test` |
| 2 | Create API key (all scopes) | Key written to `.vscode/mcp.json` and `.env.test` |
| 3 | Enable Email/Password auth | Auth method active |
| 4 | Add Flutter platform, bundle `com.lumi.app` | Platform listed in project |
| 5 | Configure SMTP: host `mailhog`, port `1025`, no TLS | Email delivery routes to Mailhog |
| 6 | Create test user `test@lumi.com` / `TestPass123!` | User ID logged |
| 7 | Create test user `reset@lumi.com` / `TestPass123!` | Used for password-reset flow |
| 8 | Write `.env.test` with all IDs and keys | File exists, git-ignored |

After step 8, the environment is ready. Subsequent `docker compose up` runs skip bootstrap — Appwrite retains state in its MariaDB volume.

---

### `.env.test` File Format

```env
APPWRITE_ENDPOINT=http://localhost/v1
APPWRITE_PROJECT_ID=lumi-test
APPWRITE_API_KEY=<api-key>
TEST_USER_EMAIL=test@lumi.com
TEST_USER_PASSWORD=TestPass123!
TEST_RESET_EMAIL=reset@lumi.com
MAILHOG_URL=http://localhost:8025
```

Add `.env.test` to `.gitignore`. Never commit API keys.

---

### Flutter Integration Test Structure

```
integration_test/
  helpers/
    appwrite_test_client.dart   # Appwrite client pointed at localhost
    test_fixtures.dart          # createTestSession(), clearTestData(), etc.
  auth/
    login_test.dart
    signup_test.dart
    forgot_password_test.dart
    auth_guard_test.dart
  bridge/
    bridge_latency_test.dart    # FRB v2 round-trip < 2ms
  screens/
    dashboard_smoke_test.dart
    home_smoke_test.dart
```

**`appwrite_test_client.dart`** reads `dart-define` values from `.env.test`:
```dart
final endpoint = const String.fromEnvironment('APPWRITE_ENDPOINT');
final projectId = const String.fromEnvironment('APPWRITE_PROJECT_ID');
```

**`test_fixtures.dart`** exposes:
- `createTestSession()` — logs in as `test@lumi.com`, returns a valid session.
- `clearTestSessions()` — deletes all sessions for the test user via Appwrite MCP (called in `tearDown`).
- `waitForEmail(String to)` — polls Mailhog REST API (`GET /api/v2/messages`) until a message to `to` arrives (timeout 10 s).

---

### Running Integration Tests

```bash
# Full suite on a connected device
flutter test integration_test/ \
  --dart-define-from-file=.env.test \
  -d <device-id>

# Single file
flutter test integration_test/auth/login_test.dart \
  --dart-define-from-file=.env.test \
  -d <device-id>

# Headless web (layout/navigation tests only — no camera/geofence)
flutter test integration_test/ \
  --dart-define-from-file=.env.test \
  -d chrome --web-renderer canvaskit

# Unit tests (no Appwrite required)
flutter test test/
```

---

### Makefile Targets

```makefile
.PHONY: services-up services-down appwrite-bootstrap appwrite-reset test-unit test-integration

services-up:
	docker compose -f docker-compose.appwrite.yml up -d
	@until curl -sf http://localhost/v1/health > /dev/null; do sleep 2; done
	@echo "✓ Appwrite ready at http://localhost"

services-down:
	docker compose -f docker-compose.appwrite.yml down

services-reset:
	docker compose -f docker-compose.appwrite.yml down -v
	$(MAKE) services-up

test-unit:
	flutter test test/

test-integration: services-up
	flutter test integration_test/ --dart-define-from-file=.env.test -d $(DEVICE)

appwrite-reset:
	@echo "Ask Copilot in agent mode to re-run the bootstrap sequence via Appwrite MCP."
	@echo "Or delete the project manually via: http://localhost/console"
```

Usage: `make test-integration DEVICE=emulator-5554`

---

### Resetting Test State Between Runs

By default, each test file's `setUp`/`tearDown` cleans up its own sessions and data via `test_fixtures.dart`. For a complete environment reset:

```bash
make services-reset   # wipes Docker volumes and restarts Appwrite
# Then ask Copilot to re-run bootstrap
```

Or for a lighter reset (preserve Appwrite project, clear test user data only):
> "Using the appwrite MCP server, delete all sessions and created documents for test@lumi.com in the lumi-test project."

---

### CI Pipeline (GitHub Actions sketch)

```yaml
jobs:
  integration-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Start Appwrite
        run: docker compose -f docker-compose.appwrite.yml up -d
      - name: Wait for health
        run: until curl -sf http://localhost/v1/health; do sleep 2; done
      - name: Bootstrap Appwrite (CI)
        # CI uses a pre-generated API key stored in GitHub secrets
        env:
          APPWRITE_API_KEY: ${{ secrets.APPWRITE_TEST_API_KEY }}
        run: bash scripts/ci-appwrite-bootstrap.sh
      - name: Flutter integration tests
        run: |
          flutter test integration_test/ \
            --dart-define-from-file=.env.test \
            -d linux    # Flutter Linux desktop for headless CI
```

`scripts/ci-appwrite-bootstrap.sh` uses the Appwrite REST API directly (no MCP needed in CI) to create the test project and users, then writes `.env.test`.
