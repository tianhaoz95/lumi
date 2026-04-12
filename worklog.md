Task: 1.1.5 Apply the No-Pure-Black Rule

Plan:
1. Search the repository for occurrences of `Colors.black`.
2. Replace production occurrences in `lib/` with `LumiColors.onSurface` and add the necessary import (`package:lumi/core/colors.dart`).
3. Update tests that reference `Colors.black` to use `LumiColors.onSurface`.
4. Run targeted tests and a search to verify no `Colors.black` remains in `lib/`.
5. Mark the roadmap task as done in `design/roadmap/phase-5-aurora.md` once all verifiable deliverables pass.

Verifiable deliverables:
- File `worklog.md` exists and contains this task and plan.
- All occurrences of `Colors.black` in `lib/` are replaced (e.g., `rg "Colors.black" lib/` returns no matches).
- `lib/shared/widgets/atmospheric_background.dart` imports `package:lumi/core/colors.dart` and uses `LumiColors.onSurface` for the grain paint.
- `test/widgets/transaction_card_test.dart` uses `LumiColors.onSurface` in its ThemeData and expectation.
- Running the updated test(s) exits with code 0: `flutter test test/widgets/transaction_card_test.dart`.

Notes:
- This work focuses only on replacing pure black usages and updating tests accordingly. Other files mentioning `Colors.black` in non-production contexts will be reviewed separately if needed.