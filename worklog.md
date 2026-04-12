Task: 4.2.1 Implement TransactionCard widget

Planned steps:
1. Inspect UI folders to find appropriate place for TransactionCard (lib/features/... or lib/shared/widgets).
2. Create a reusable TransactionCard widget at lib/features/transactions/widgets/transaction_card.dart implementing the fields and behavior described in the roadmap.
3. Add a lightweight widget test at test/widgets/transaction_card_test.dart that verifies: AI badge rendering when is_tagged=true, amount color logic, and Confirm button calls the provided callback.
4. Add minimal exports/imports so the widget is discoverable.
5. Mark the roadmap task as done in design/roadmap/phase-3-snowpack.md.

Verifiable deliverables:
- File `lib/features/transactions/widgets/transaction_card.dart` exists and declares `class TransactionCard`.
- File `test/widgets/transaction_card_test.dart` exists and contains tests asserting AI badge, amount color, and Confirm callback invocation (can be run with `flutter test`).
- `design/roadmap/phase-3-snowpack.md` has the task 4.2.1 checked (`- [x]`).

Notes:
- Tests are written assuming Flutter test tooling; if Flutter SDK is unavailable, reviewers can still verify file contents and run tests in CI with Flutter installed.
- Do not delete this worklog; reviewer will inspect it.
