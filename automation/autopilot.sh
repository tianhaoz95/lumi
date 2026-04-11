#!/usr/bin/env bash
# autopilot.sh — Autonomous Lumi implementation loop.
# Runs up to 1000 iterations; each iteration picks the next unchecked task
# from ./design/roadmap, implements it, tests it, then marks it done.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROADMAP_DIR="$REPO_ROOT/design/roadmap"
IMPL_PLAN="$REPO_ROOT/design/IMPLEMENTATION_PLAN.md"
PRD="$REPO_ROOT/design/PRD.md"
MAX_ITERATIONS=200
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

### Step 0: Verify integration tests are green (do this FIRST, before any other work)

Run the existing integration test suite:

```
make test-integration DEVICE=linux
```

If any tests fail:
a. Read the failure output carefully to understand the root cause.
b. Trace the failure to the responsible source file(s) in `integration_test/`,
   `lib/`, or `rust/` and fix the defect.
c. Re-run the integration tests until they all pass.
d. Do NOT proceed to Step 1 until the full suite is green.

If the Appwrite service is not reachable, start it first with:
```
docker compose -f docker-compose.appwrite.yml up -d
until curl -sf http://localhost/v1/health > /dev/null; do sleep 2; done
```

Only skip an integration test if it requires hardware (e.g., NPU/camera) that
is genuinely unavailable; leave a clearly-worded TODO comment in that test file.

---

1. **Find the next task** — Scan every `- [ ]` checkbox in the files under
   `./design/roadmap/` (phase-1-permafrost.md, phase-2-thaw.md, …).
   Pick the first unchecked item in the lowest-numbered phase file.
   Print the exact task ID and description so it is clear which task you chose.

2. **Check for prior failure notes** — Look for a file at `./verify_note.md`.
   If it exists, search for a section whose heading matches the task you just
   picked (e.g. `## [<task description>]`).
   If a matching section is found, read it carefully — it contains the root
   cause, specific findings, and suggested fix from a previous failed attempt.
   Use this information as mandatory context when planning and implementing;
   do not repeat the same mistakes.

3. **Load context** — Read the following files in full before planning:
   - `./design/IMPLEMENTATION_PLAN.md`
   - `./design/PRD.md`

4. **Generate an implementation plan** — Write a concise, step-by-step plan
   specific to this task. Include file paths, function signatures, and any
   dependency commands needed.

5. **Implement the task** — Follow your plan exactly. Create or edit all
   necessary source files. Follow the architecture defined in the Copilot
   instructions (Flutter 3.x / FRB v2 / Rig / sea-orm / LanceDB / Gemma 4).
   Respect the "Glacial Sanctuary" design system tokens and visual rules.

6. **Write tests** — Add unit and/or integration tests that verify the task's
   "Verifiable result" criterion stated in the roadmap. Place tests in the
   appropriate location (Flutter: `test/` or `integration_test/`; Rust:
   `#[cfg(test)]` modules or `tests/`).

7. **Run the tests** — Execute the relevant test command(s) and confirm they
   pass. If a test fails, debug and fix the implementation before proceeding.

8. **Mark the task done** — After all tests pass, update the roadmap file:
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

## ⚠️ Important: your work will be independently verified

After you mark a task done, **Gemini** will review your implementation by:
- Reading the task's success criteria from the roadmap
- Inspecting every file you changed (`git diff HEAD`)
- Running the associated tests itself

If Gemini finds the implementation incomplete or the tests failing, the task
will be unchecked and you will have to redo it in the next iteration — wasting
a full round. To avoid this:
- Double-check that every success criterion stated in the roadmap is met.
- Run the tests yourself before flipping the checkbox; do not mark done if
  anything is red.
- Leave no stubs, TODOs, or placeholder implementations in production code
  paths (only in genuinely hardware-gated test cases as described above).
PROMPT_EOF
)

  log "Invoking copilot for task $i…"
  copilot \
    --yolo \
    --model "$MODEL" \
    -p "$PROMPT"

  # ── Gemini verification pass ──────────────────────────────────────────────
  # Find the task that copilot just marked done (newly flipped - [x] in roadmap).
  COMPLETED_TASK=$(git -C "$REPO_ROOT" diff -- "$ROADMAP_DIR" \
    | grep '^+- \[x\]' | sed 's/^+- \[x\] //' | head -1)

  if [[ -z "$COMPLETED_TASK" ]]; then
    log "WARNING: copilot did not mark any task done this iteration."
  else
    log "Asking Gemini to verify: $COMPLETED_TASK"

    VERIFY_NOTE="$REPO_ROOT/verify_note.md"

    GEMINI_PROMPT=$(cat <<GEMINI_EOF
You are an independent QA engineer reviewing a completed implementation in the
Lumi repository (privacy-first Flutter + Rust bookkeeping app).

## Task that was just implemented

"$COMPLETED_TASK"

## Your job

1. Open the roadmap file(s) under \`./design/roadmap/\` and locate this task.
   Read its full entry, including the "Verifiable result" or success-criteria
   section.

2. Inspect every file changed or created since the last git commit
   (\`git diff HEAD\`) to understand what copilot actually built.

3. Run any tests associated with this task (unit tests, integration tests,
   or build checks) to confirm they pass. Use the same commands the roadmap
   specifies; fall back to \`flutter test\` and \`cargo test\` if unspecified.

4. Judge whether the implementation fully satisfies the task's success criteria.

5. If the verdict is VERIFICATION_FAILED, you MUST also:
   a. Identify the exact root cause(s) — failed tests, missing criteria,
      broken logic, wrong file, etc.
   b. Append a structured failure note to \`./verify_note.md\` using this
      format (append, never overwrite the whole file):

      ## [$COMPLETED_TASK]
      **Verdict:** FAILED
      **Root cause:**
      <concise explanation of what is wrong>
      **Specific findings:**
      - <finding 1: file, line, or test name + what is wrong>
      - <finding 2: …>
      **Suggested fix:**
      <actionable steps copilot should take to resolve this>

6. Output your verdict as the very last line of your response — exactly one of:
     VERIFICATION_PASSED
     VERIFICATION_FAILED

   Do not add any other text on that final line.
   Before the verdict, briefly explain your reasoning (2-5 sentences).
GEMINI_EOF
)

    GEMINI_OUTPUT=$(gemini --yolo -p "$GEMINI_PROMPT" 2>&1)
    log "Gemini output:"
    echo "$GEMINI_OUTPUT"

    if echo "$GEMINI_OUTPUT" | tail -5 | grep -q "VERIFICATION_FAILED"; then
      log "Gemini verification FAILED — unchecking task so copilot retries next round."
      # Revert only the roadmap checkbox changes; keep all implementation files.
      git -C "$REPO_ROOT" checkout -- "$ROADMAP_DIR"
    else
      log "Gemini verification PASSED — task accepted."
    fi
  fi
  # ─────────────────────────────────────────────────────────────────────────

  log "Iteration $i complete."
done

log "Reached $MAX_ITERATIONS iterations. Stopping."
