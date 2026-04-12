Task: Create integration_test/golden_path_test.dart

Planned steps:
1. Create this worklog.md describing the task and deliverables.
2. Add a new integration test file at integration_test/golden_path_test.dart containing a scaffolded Golden Path E2E test with clearly named test cases covering: Onboarding/SignUp, Login, Dashboard Load, Chat Interaction, Receipt Logging (mock), and Logout.
3. Mark the task done in midterm-polish-tasks.md by checking the corresponding box.
4. Commit the new files and the updated task list.

Verifiable deliverables:
- File integration_test/golden_path_test.dart exists and contains tests named: "Onboarding/SignUp", "Login", "Dashboard Load", "Chat Interaction", "Receipt Logging", "Logout".
- worklog.md exists and documents the task, plan, and deliverables (this file).
- The task line in midterm-polish-tasks.md is changed from "- [ ] Create integration_test/golden_path_test.dart" to "- [x] Create integration_test/golden_path_test.dart".

Notes for reviewer:
- The tests are scaffolded and marked skip by default because they require a running Appwrite and a device. To run, enable them and ensure Appwrite and a device are available, then run: `make test-integration DEVICE=linux` or equivalent.
