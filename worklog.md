Task: Implement chat InsightCard rendering for tool results (Phase 3 — task 4.3.2)

Planned steps:
1. Locate chat / HomeScreen and agent_chat integration in the Flutter codebase.
2. Identify how agent tool-result chunks are represented in the stream (look for AgentChunk or tool-result handling).
3. Implement a new InsightCard widget (if missing) under lib/features/chat/widgets/insight_card.dart that can render two variants: Summary (get_summary) and TransactionList (query_transactions).
4. Update chat message handling to detect tool-result chunks from agent_chat and insert an InsightCard into the chat message list instead of plain text.
5. Add widget tests for InsightCard rendering for both variants and a widget test ensuring chat renders InsightCard when a tool-result chunk is emitted.
6. Run Flutter widget tests (if available) and ensure builds succeed.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- New file `lib/features/chat/widgets/insight_card.dart` exists and exports InsightCard widget.
- Chat message handler updated (`lib/features/home/home_impl.dart` and related chat handler) to render InsightCard when agent emits a tool-result chunk.
- Widget tests added: `test/widgets/insight_card_test.dart` and `test/widgets/chat_insight_test.dart` and they pass when `flutter test` is run (exit code 0).
- Manual verification steps documented below (copy/paste-ready) describing how to trigger tool calls and expected UI outcomes.

Manual verification steps (copy/paste-ready):
- Start the app: `flutter run` and open the Home screen.
- In the chat input, enter: "Show me my summary" and tap send.
- The Rig-backed agent should emit a JSON tool-result chunk with the shape:
  {"insight_type":"summary","summary":{"total_expenses":<num>,"total_miles":<num>,"estimated_deduction":<num>}}.
- The chat bubble should render an InsightCard showing "Summary", the formatted total expenses (e.g., "$88.50"), total miles (e.g., "5.0 mi"), and estimated deduction (e.g., "$3.35").
- For transaction lists: send a prompt like "Show me my expenses for March"; the agent should emit {"insight_type":"transactions","transactions":[{...}]}, and the chat should render a Transactions InsightCard with compact TransactionCard entries.

Notes:
- If the project lacks a Flutter test harness or CI, add only minimal widget tests and ensure `flutter test` runs without new failures.
- Keep changes minimal and confined to chat-related files.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>

Reviewer Findings:
1) Missing manual verification steps: The worklog claims manual verification steps are documented, but none are present. Add explicit steps so a reviewer or QA can exercise the feature manually.

   Recommended manual steps (copy/paste-ready):
   - Start the app: flutter run and open the Home screen.
   - In the chat input, enter: "Show me my summary" and tap send.
   - The Rig-backed agent should emit a JSON tool-result chunk with the shape:
     {"insight_type":"summary","summary":{"total_expenses":<num>,"total_miles":<num>,"estimated_deduction":<num>}}.
   - The chat bubble should render an InsightCard showing "Summary", the formatted total expenses (e.g., "$88.50"), total miles (e.g., "5.0 mi"), and estimated deduction (e.g., "$3.35").
   - For transaction lists: send a prompt like "Show me my expenses for March"; the agent should emit {"insight_type":"transactions","transactions":[{...}]}, and the chat should render a Transactions InsightCard with compact TransactionCard entries.

2) Test file path mismatch: The worklog listed tests under `test/widget/` but repository contains them in `test/widgets/` (plural). Tests exist and passed during verification, but update worklog to reflect actual paths or rename test files to match the stated paths.

3) Minor UI detail: In lib/features/chat/widgets/insight_card.dart the TransactionCard is constructed with `isTagged: t.isCredit` and `onConfirm: null`. Confirm this is intentional (using `isCredit` as a proxy for tagging) and provide a non-null `onConfirm` callback if user interaction is required. Not a blocker for this task, but worth noting.

Summary: The implementation exists, widget tests were added and both executed successfully (flutter test exit code 0). The single verifiable shortcoming is the missing manual verification steps in the worklog and a small mismatch in the expected test file paths. Please update worklog.md to include the manual steps (the recommended steps are above) and either adjust test filenames or the worklog to match the repository.
