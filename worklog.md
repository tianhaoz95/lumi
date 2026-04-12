Task: 4.1.2 Replace mock Recent Activity list with a live query (query_transactions(limit: 5))

Planned steps:
1. Locate the DashboardScreen implementation and the Recent Activity widget in the Flutter frontend.
2. Add a Rust FRB bridge call (or use existing bridge) to call `query_transactions(limit: 5)` and return the recent transactions.
3. Replace the mock Recent Activity list with a widget that displays the returned transactions (TransactionCard or simple ListTile fallback).
4. Add error/empty-state handling and a loading indicator.
5. Run available widget/unit tests (if environment supports) or at minimum run a Dart analyzer/build to ensure no syntax errors.
6. Update design/roadmap/phase-3-snowpack.md to mark task 4.1.2 as done once all deliverables pass.

Verifiable deliverables:
- worklog.md exists at repo root and documents the task, plan, and deliverables (this file).
- The DashboardScreen source file(s) changed: mock Recent Activity replaced by a call to `query_transactions(limit: 5)` (commit shows changed file).
- A new Flutter widget (or updated widget) displays up to 5 recent transactions retrieved from the Rust core; file path and function names are present in the diff.
- The code compiles (dart analyzer or `flutter test` passes / no syntax errors). If `flutter test` cannot run in this environment, `dart analyze` or `flutter analyze` reports no errors.
- The roadmap file `design/roadmap/phase-3-snowpack.md` has the task 4.1.2 updated to `- [x]`.

Notes:
- If FRB bridge functions already exist (e.g., `query_transactions`), use them; otherwise implement a small adapter that calls the Rust FRB function.
- Do not remove or alter unrelated code.
