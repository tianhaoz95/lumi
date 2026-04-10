#!/usr/bin/env bash
# autopilot.sh — Autonomous Lumi implementation loop.
# Runs up to 1000 iterations; each iteration picks the next unchecked task
# from ./design/roadmap, implements it, tests it, then marks it done.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROADMAP_DIR="$REPO_ROOT/design/roadmap"
IMPL_PLAN="$REPO_ROOT/design/IMPLEMENTATION_PLAN.md"
PRD="$REPO_ROOT/design/PRD.md"
MAX_ITERATIONS=1000
MODEL="gpt-5-mini"

log() { echo "[autopilot] $*"; }

# Returns true if any unchecked task ( "- [ ]" ) remains across all roadmap files.
has_pending_tasks() {
  echo "Checking for pending tasks in $ROADMAP_DIR..."
  grep -rl --include="*.md" -- "- \[ \]" "$ROADMAP_DIR" | grep -q .
}

for i in $(seq 1 "$MAX_ITERATIONS"); do
  log "━━━ Iteration $i / $MAX_ITERATIONS ━━━"

  if ! has_pending_tasks; then
    log "All tasks in the roadmap are complete. Stopping."
    exit 0
  fi

  PROMPT=$(cat <<'PROMPT_EOF'
You are an autonomous engineer working on the Lumi project (a privacy-first,
local-first, agentic bookkeeping Flutter + Rust app).

## Your mission for this iteration

1. **Find the next task** — Scan every `- [ ]` checkbox in the files under
   `./design/roadmap/` (phase-1-permafrost.md, phase-2-thaw.md, …).
   Pick the first unchecked item in the lowest-numbered phase file.
   Print the exact task ID and description so it is clear which task you chose.

2. **Load context** — Read the following files in full before planning:
   - `./design/IMPLEMENTATION_PLAN.md`
   - `./design/PRD.md`

3. **Generate an implementation plan** — Write a concise, step-by-step plan
   specific to this task. Include file paths, function signatures, and any
   dependency commands needed.

4. **Implement the task** — Follow your plan exactly. Create or edit all
   necessary source files. Follow the architecture defined in the Copilot
   instructions (Flutter 3.x / FRB v2 / Rig / sea-orm / LanceDB / Gemma 4).
   Respect the "Glacial Sanctuary" design system tokens and visual rules.

5. **Write tests** — Add unit and/or integration tests that verify the task's
   "Verifiable result" criterion stated in the roadmap. Place tests in the
   appropriate location (Flutter: `test/` or `integration_test/`; Rust:
   `#[cfg(test)]` modules or `tests/`).

6. **Run the tests** — Execute the relevant test command(s) and confirm they
   pass. If a test fails, debug and fix the implementation before proceeding.

7. **Mark the task done** — After all tests pass, update the roadmap file:
   change the checkbox for the task you completed from `- [ ]` to `- [x]`.
   Do not change any other checkboxes.

## Constraints
- Never modify `./design/roadmap/*.md` files except to flip `- [ ]` → `- [x]`
  for the single task you completed in this iteration.
- Stay within the repository root. Do not commit or push.
- If the task requires an external service (e.g., Appwrite) that is not
  running, skip the integration test and leave a TODO comment; still mark the
  task done if the unit-testable portion passes.
- Do not skip tasks — work strictly in order.
PROMPT_EOF
)

  log "Invoking copilot for task $i…"
  copilot \
    --yolo \
    --model "$MODEL" \
    -p "$PROMPT"

  log "Iteration $i complete."
done

log "Reached $MAX_ITERATIONS iterations. Stopping."
