Task: Implement Phase 3 task 4.2.2 — After receipt OCR, render a TransactionCard for user confirmation before saving.

Planned steps:
1. Locate the existing receipt OCR bridge and the TransactionCard widget.
2. Modify the dev DiagnosticsScreen to parse a sample receipt and render TransactionCard for confirmation after OCR.
3. Add a widget test that pumps DiagnosticsScreen, triggers the sample receipt processing, and asserts a TransactionCard appears with correct fields.
4. Run the widget test to verify the UI flow works.

Verifiable deliverables:
- worklog.md exists at project root containing this plan.
- File lib/features/dev/diagnostics_screen.dart updated to render TransactionCard when a receipt is processed.
- New widget test test/dev/diagnostics_receipt_flow_test.dart exists and passes.
- Running `flutter test test/dev/diagnostics_receipt_flow_test.dart` exits with code 0 (test passes).
