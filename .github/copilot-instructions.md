# Lumi – Copilot Instructions

## Project Status

This repository is in the **design / pre-implementation phase**. The codebase does not yet exist; only the PRD and approved UI mockups are present. Implementation should follow the architecture and conventions documented here.

---

## Architecture ("The Glacier")

Lumi is a **privacy-first, local-first, agentic bookkeeping app**. All PII stays on-device — no cloud uploads.

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Impeller renderer) |
| Agentic UI | Flutter AI Toolkit (chat + multimodal input) |
| Dynamic Widgets | GenUI SDK (model-driven interactive widgets) |
| Dart/Rust Bridge | flutter_rust_bridge v2 (FRB v2, streaming SSE) |
| Agentic Core | Rig (Rust) — memory, tool-calling, RAG |
| Local Inference | LiteRT-LM (NPU-accelerated) |
| Models | Gemma 4 E2B (background "Sentinel") + Gemma 4 E4B (foreground "Auditor") |
| Relational DB | SQLite via sea-orm (Rust) |
| Vector / RAG DB | LanceDB |

The **FRB v2 bridge** is the only boundary between Flutter (Dart) and the Rust core. Target round-trip latency: < 2 ms.

### Agentic Tools (Rig)

The Rust Rig agent exposes named tools the LLM can call: `log_to_db`, `query_history`, and others to be added. When implementing new capabilities, expose them as Rig tools rather than hardcoding logic in the Flutter layer.

### Proactive Sentinel

`BackgroundGuard` wakes the E2B model hourly to scan for untagged transactions or missing receipts. A separate geofence trigger (flutter_background_geolocation) fires when the user leaves a known vendor location.

---

## Design System ("The Glacial Sanctuary")

Screens are defined as approved HTML mockups in `design/ui_design/<screen>/code.html`. These are the source of truth for Flutter widget implementation.

### Color Tokens (Material You – "Deep Pine Frost")

| Token | Value |
|---|---|
| `primary` | `#00464a` |
| `primary-container` | `#006064` |
| `surface` / `background` | `#f5fafc` |
| `on-surface` | `#171c1e` (never use pure `#000000`) |
| `surface-container-lowest` | `#ffffff` |
| `surface-container-high` | `#e4e9eb` |
| `outline-variant` | `#bec8c9` |

### Typography

- **Manrope** — Display & Headline (`letter-spacing: -0.02em`)
- **Inter** — Body & Labels (`line-height: 1.6×`)
- Use extreme scale contrast (e.g., `display-lg` title next to a `label-md` caption).

### Key Visual Rules

- **No divider lines.** Separate elements with tonal background shifts or 1.5–2 rem of vertical whitespace.
- **No hard borders.** Define containers with tonal surface nesting or glassmorphism (`backdrop-blur: 20–40px`, surface at 70% opacity).
- **Ghost Borders only** when WCAG demands an outline: `outline-variant` at 15% opacity.
- **Primary CTAs:** `border-radius: 9999px` (full pill), gradient from `primary` → `primary-container` at 135°.
- **All corners:** minimum 16px radius — no sharp corners anywhere.
- **Animations:** 300–500 ms ease-out only. No high-velocity transitions.
- **Shadows:** `on-surface` at 4–6% opacity, `blur: 40px`, `y-offset: 12px`. Felt, not seen.
- **Floating navigation:** glassmorphism pill, does not span full screen width.

### Kit the Fox (Mascot)

Kit appears as a ghost element (5–10% opacity) in card backgrounds, or as minimal line-art in onboarding titles. Pair `headline-sm` greeting text with a low-opacity Kit icon in empty states.

---

## Implementation Roadmap Phases

When implementing, follow this phase order:

1. **Permafrost** — Flutter + FRB v2 scaffold; Rust core with sea-orm + LanceDB; base GenUI widgets.
2. **Thaw** — LiteRT-LM integration in Rust; Gemma model loading; token streaming to Flutter AI Toolkit.
3. **Snowpack** — Rig agent + tools; local RAG pipeline.
4. **Sentinel** — BackgroundGuard heartbeat; geofence triggers; notification logic.
5. **Aurora** — "Cozy Cabin" theme polish; Kit the Fox animations; SHA-256 audit trail; PDF export.

---

## Screen Inventory

Approved mockups (HTML + PNG) exist for:

- `login`, `sign_up`, `forgot_password`
- `home`, `dashboard`, `settings`

Each screen directory under `design/ui_design/<screen>/` contains `code.html` (reference implementation) and `screen.png` (visual target).

---

## Test Automation with Local Appwrite

Full integration tests require a locally hosted Appwrite instance and are initialised via the **Appwrite MCP server**. See `design/IMPLEMENTATION_PLAN.md` §"Testing Automation" for the complete guide. Quick reference:

### 1. Start services

```bash
docker compose -f docker-compose.appwrite.yml up -d
# Wait for health
until curl -sf http://localhost/v1/health > /dev/null; do sleep 2; done
```

### 2. Configure Appwrite MCP (`.vscode/mcp.json`, git-ignored)

```json
{
  "servers": {
    "appwrite": {
      "command": "uvx",
      "args": ["mcp-server-appwrite"],
      "env": {
        "APPWRITE_ENDPOINT": "http://localhost/v1",
        "APPWRITE_PROJECT_ID": "lumi-test",
        "APPWRITE_API_KEY": "<key-generated-during-bootstrap>"
      }
    }
  }
}
```

### 3. Bootstrap project (first time only) — ask Copilot in agent mode

> "Using the appwrite MCP server, initialise the lumi-test project for integration testing."

Copilot will run the bootstrap sequence: create project → generate API key → enable email/password auth → add Flutter platform → configure Mailhog SMTP → create test users → write `.env.test`.

### 4. Run integration tests

```bash
# Full suite
flutter test integration_test/ --dart-define-from-file=.env.test -d <device-id>

# Single file
flutter test integration_test/auth/login_test.dart --dart-define-from-file=.env.test -d <device-id>

# Makefile shortcut
make test-integration
```

### 5. Reset state between runs

```bash
make appwrite-reset   # drops and recreates the lumi-test project via Appwrite MCP
docker compose -f docker-compose.appwrite.yml down -v   # full wipe including volumes
```

**Rule:** `.env.test` must always point to `http://localhost`. Never use a shared or production Appwrite endpoint in tests.
