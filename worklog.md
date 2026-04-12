# Worklog — Phase 5 Task

Task: Create `design_debt` SQLite table (dev-only, not shipped) as specified in `design/roadmap/phase-5-aurora.md` (1.1.2).

Planned steps:
1. Add a SQL migration file at `rust/migrations/0001_create_design_debt.sql` containing the CREATE TABLE statement from the roadmap.
2. Apply the migration to the local development DB `lumi_test.db` to verify the table is created.
3. Add a small Rust unit test placeholder (if migrations are managed in Rust) or a verification script to ensure the table exists.
4. Commit the migration and the worklog entry.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- File `rust/migrations/0001_create_design_debt.sql` exists and contains the exact CREATE TABLE statement.
- Running `sqlite3 lumi_test.db ".tables"` shows `design_debt` in the list.
- Running `sqlite3 lumi_test.db "PRAGMA table_info('design_debt');"` returns the four columns: id, screen, description, status.

Notes:
- This is a dev-only migration; no app runtime code is modified.
- If the project uses a different migration system, the SQL file is placed in `rust/migrations/` for reviewer convenience.


Reviewer Findings:

Summary:
- The `design_debt` table exists in `lumi_test.db` and has the expected columns (id, screen, description, status with default 'open').
- The migration file `rust/migrations/0001_create_design_debt.sql` differs from the roadmap's SQL: it uses `CREATE TABLE IF NOT EXISTS` instead of the exact `CREATE TABLE` statement requested in the roadmap/worklog.

Details:
- File: rust/migrations/0001_create_design_debt.sql
  * Expected (from roadmap/worklog):
    CREATE TABLE design_debt (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      screen TEXT,
      description TEXT,
      status TEXT DEFAULT 'open'
    );
  * Found in repository:
    CREATE TABLE IF NOT EXISTS design_debt (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      screen TEXT,
      description TEXT,
      status TEXT DEFAULT 'open'
    );

Why this matters:
- The worklog explicitly required the "exact CREATE TABLE statement." If the requirement is strict, the extra `IF NOT EXISTS` means the deliverable is not an exact match and must be corrected.
- Functionally, `IF NOT EXISTS` is harmless and often desired for idempotent migrations, but the reviewer must follow the worklog's acceptance criteria.

Recommendations / Required fixes:
1. If the intent was to require an exact textual match with the roadmap, update `rust/migrations/0001_create_design_debt.sql` to remove `IF NOT EXISTS` so it matches exactly. After changing, re-run the DB verification (or recreate the DB) and confirm the same sqlite3 checks succeed.

   Command to re-verify:
   sqlite3 lumi_test.db ".tables"
   sqlite3 lumi_test.db "PRAGMA table_info('design_debt');"

2. If `IF NOT EXISTS` is acceptable (preferred for idempotency), update this worklog to state that the migration may include `IF NOT EXISTS` and consider the deliverable satisfied. In that case, also note this decision in the commit message.

Current verification performed (by reviewer):
- `sqlite3 lumi_test.db ".tables"` shows `design_debt` present.
- `sqlite3 lumi_test.db "PRAGMA table_info('design_debt');"` returned columns: id, screen, description, status (status default 'open').

Action requested from worker:
- Confirm whether `IF NOT EXISTS` is acceptable. If not, apply the fix described in (1), commit, and notify reviewer. If acceptable, update the worklog text to relax the "exact" requirement and include a short note explaining why `IF NOT EXISTS` was used.

Status: Pending change (see recommended fixes).

Worker actions:

- Updated `rust/migrations/0001_create_design_debt.sql` to remove `IF NOT EXISTS` so the SQL matches the roadmap exactly.
- Committed migration and updated roadmap to mark task 1.1.2 as done.
- Verified local DB `lumi_test.db` contains `design_debt` table and its columns.

Verification commands run locally:

```
sqlite3 lumi_test.db ".tables"            -- shows design_debt present
sqlite3 lumi_test.db "PRAGMA table_info('design_debt');"  -- shows id, screen, description, status (default 'open')
```

Status: Fixed and verified locally.

---

Next task started: 1.1.3 — Apply the No-Line Rule

Task: Apply the No-Line Rule across the app: remove explicit Divider() widgets and Container/BoxDecoration borders in production screens; replace visual separators with tonal shifts (boxShadow, background tonal surfaces) or increased spacing.

Planned steps:
1. Search the Flutter codebase for explicit `Divider(`, `Border.all(`, and other `border:` usages in `lib/`.
2. Replace explicit 1px borders with subtle `boxShadow` or remove them where spacing suffices.
3. Prefer tonal shifts (use existing LumiColors tokens) over hard borders.
4. Run a quick code search to verify no remaining `Border.all(..., width: 1.0)` occurrences in `lib/`.
5. Commit changes and update roadmap (mark task 1.1.3 done).

Verifiable deliverables:
- All edits are committed to the repository.
- No `Divider(` occurrences in `lib/` (search returns none).
- No `Border.all(..., width: 1.0)` occurrences in `lib/` (search returns none).
- `design/roadmap/phase-5-aurora.md` shows task 1.1.3 marked as done.

Notes:
- This change replaces visual 1px borders with `BoxShadow` entries to maintain visual separation without explicit border lines, following the No-Line Rule.
