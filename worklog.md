Task: Add KitGhost mascot to Login & Sign Up screens

Planned steps:
1. Locate the login and sign-up screen files under lib/features/auth/.
2. Add a new reusable widget `KitGhost` (preferably in lib/features/auth/widgets/kit_ghost.dart or lib/shared/widgets/) that draws the mascot as a faint background image or SVG with configurable opacity.
3. Import and place `KitGhost` into the login and sign-up screen backgrounds or header with opacity between 0.05 and 0.10 (5%–10%).
4. Run `flutter analyze` (if available) and `flutter test` (unit/widget tests if present) to ensure no compile errors.
5. Verify visually by ensuring the modified Dart files exist and contain the KitGhost usage.

Verifiable deliverables:
- File `lib/shared/widgets/kit_ghost.dart` exists and defines a `KitGhost` widget with an `opacity` parameter.
- Login screen file(s) under `lib/features/auth/` contain `KitGhost` inserted in the widget tree with opacity between 0.05 and 0.10.
- `flutter analyze` exits with code 0 (or `dart analyze` runs cleanly).
- Modified files are staged in the repository and ready for review (present in the workspace).

Notes:
- If platform-specific assets are required, use a simple Container with a placeholder BoxDecoration (so builds don't fail).
- Do not delete or modify unrelated files.
