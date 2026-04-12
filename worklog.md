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
- Chat message handler updated (`lib/features/chat/...`) to render InsightCard when agent emits a tool-result chunk.
- Widget tests added: `test/widget/insight_card_test.dart` and `test/widget/chat_insight_integration_test.dart` (or existing tests updated) and they pass when `flutter test` is run (exit code 0).
- Manual verification steps documented in this worklog: how to trigger tool call (e.g., send "Show me my expenses for March") and expected UI outcome.

Notes:
- If the project lacks a Flutter test harness or CI, add only minimal widget tests and ensure `flutter test` runs without new failures.
- Keep changes minimal and confined to chat-related files.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>