Task: Confirm all modals and bottom sheets use the glassmorphism card template (Phase 5 — 1.2.3)

Planned steps:
1. Search the Flutter codebase for modal and bottom sheet usages (showModalBottomSheet, showDialog, BottomSheet, showCupertinoModalPopup, showGeneralDialog).
2. Create or locate a glassmorphism card template widget (e.g., `GlassCard` / `GlassModal`) in `lib/shared/` or `lib/widgets/`. If not present, implement a reusable `GlassModal` widget using BackdropFilter + frosted surface color at 70% opacity.
3. Replace or wrap all modal/bottom sheet builders to use `GlassModal` / `GlassCard` template.
4. Run `flutter test` (existing widget tests) or at least run `flutter analyze` / `dart pub get` to ensure no compile errors.
5. Add a small widget test verifying that `showModalBottomSheet` uses `GlassModal` (or that modal widget tree contains `BackdropFilter` and the expected color token).
6. Commit changes and update the roadmap file to mark 1.2.3 done when all verifiable deliverables pass.

Verifiable deliverables:
- File `worklog.md` exists and lists the task and plan (this file).
- A reusable `GlassModal` widget exists at `lib/shared/glass_modal.dart` (or similar) and uses `BackdropFilter` with sigmaX/Y >= 20 and surface-container-lowest color at 70% opacity.
- All occurrences of `showModalBottomSheet`/`showDialog`/bottom sheets in `lib/` are updated to use the `GlassModal` template (or their builders include `BackdropFilter` + correct opacity).
- A new widget test `test/widgets/glass_modal_test.dart` asserts that the modal widget tree contains `BackdropFilter` and the expected color token.
- `flutter analyze` exits with code 0 (no analyzer errors).
- The roadmap line `1.2.3 Confirm all modals and bottom sheets use the glassmorphism card template` is marked done in `design/roadmap/phase-5-aurora.md` once all above deliverables pass.
