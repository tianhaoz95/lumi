Task: Implement TransactionCard confirmation flow (4.2.3 in phase-3-snowpack.md)

Planned steps:
1. Add a Dart FRB bridge method to call the Rust `log_transaction` tool from Flutter.
2. Wire the DiagnosticsScreen TransactionCard "Confirm" button to call the bridge and persist the parsed receipt.
3. Implement an "Edit" dialog that allows editing vendor, category, date, amount, currency before confirming; on save, call the same bridge.
4. Keep existing "Dismiss" behavior (clears the parsed receipt).
5. Run a quick Dart analyzer (flutter analyze) if available and run unit/widget tests if present for the modified files.

Verifiable deliverables:
- File `lib/shared/bridge/lumi_core_bridge.dart` contains a `logTransaction` static method that invokes the native `log_transaction` MethodChannel.
- `lib/features/dev/diagnostics_screen.dart`'s TransactionCard `onConfirm` calls `LumiCoreBridge.logTransaction` and shows a SnackBar with the returned ID; after success the receipt is cleared.
- `lib/features/dev/diagnostics_screen.dart`'s `onEdit` shows an edit dialog, allows changing fields, and on Save calls `logTransaction` with edited values.
- `worklog.md` exists at project root with the above plan and deliverables.
- Running `flutter analyze` (or `dart analyze`) should not report errors in the edited files.

Notes:
- This implements the UI-side wiring for confirm/edit/dismiss; the Rust native implementation is assumed present per roadmap.
- The reviewer can verify by opening the Diagnostics screen, pressing "Process Sample Receipt" and then confirming or editing to persist; success shows a SnackBar with an ID.