Task: Implement "Chat Interaction" step in integration_test/golden_path_test.dart

Plan:
1. Open integration_test/golden_path_test.dart and locate the Chat Interaction test step.
2. If the test currently sends a message and expects an echo, modify the test to expect a non-echo response or add a mock that returns an appropriate Lumi response.
3. If necessary, add a simple mock service or test helper to simulate Lumi's chat response (non-echo), ensuring it does not depend on network or external models.
4. Run the integration tests (or just the golden_path_test.dart) with DEVICE=linux and confirm the Chat Interaction step passes.
5. Update midterm-polish-tasks.md to mark the Chat Interaction item as done when verified.

Verifiable deliverables:
- File worklog.md exists and lists the task, plan, and deliverables (this file).
- integration_test/golden_path_test.dart updated so the Chat Interaction step expects a non-echo response and/or uses a mock.
- Running `flutter test integration_test/golden_path_test.dart --device-id=linux` (or `make test-integration DEVICE=linux`) completes with exit code 0 for the Chat Interaction step (or the single-test run passes locally).
- midterm-polish-tasks.md updated: the line for "Chat Interaction" changed from "- [ ]" to "- [x]".
