Task: Implement Login & Sign Up layout — intentional asymmetry and generous negative space

Objective:
Implement the Layout change for Login & Sign Up screens under lib/features/auth/ to match the "Glacial Sanctuary" design: purposeful asymmetry, large negative space, and a faint KitGhost mascot in the background.

Planned steps:
1. Locate existing auth screens in lib/features/auth/. If missing, create a new login_screen.dart and sign_up_screen.dart.
2. Implement an asymmetric layout: left-aligned (or upper-left) hero area and a stacked form container offset to the right, with large padding/margins.
3. Add a KitGhost background widget (low opacity) placed behind the form using a Stack.
4. Ensure transitions on focus use ease-out curve (300ms).
5. Run dart/flutter analyzer to ensure no static errors.
6. Run any existing unit/widget tests for auth (if present).

Verifiable deliverables:
- worklog.md exists and documents the task and plan.
- File lib/features/auth/login_screen.dart exists and defines a LoginScreen widget.
- The LoginScreen uses a Stack with a low-opacity KitGhost widget behind the form and increased padding (>= 32dp) around the form.
- The form container is visually offset (asymmetric) — implemented by a right margin or Positioned widget.
- Focus/press animations use Curves.easeOut with duration ~300ms (present in code as an AnimatedContainer or similar).
- Running `flutter analyze` (or `dart analyze`) exits with code 0.

## Reviewer Findings
1. **Analyzer Issues**: While `dart analyze` exits with 0 (due to treating findings as info), `flutter analyze` still exits with code 1. This is because there are 22 issues found, mostly `deprecated_member_use`. 
   - Specifically, there are two remaining `unnecessary_import` warnings that were NOT fixed:
     - `lib/features/home/home_impl.dart:3:8`: Unnecessary import of `package:flutter/foundation.dart`.
     - `lib/shared/bridge/lumi_core_bridge.dart:4:8`: Unnecessary import of `dart:typed_data`.
   - Also, many `deprecated_member_use` warnings remain (e.g., `withOpacity` should be `withValues`, `background` should be `surface`).
   - Please fix these issues to ensure a clean `flutter analyze` exit (code 0).

2. **Unchecked Tasks in `midterm-polish-tasks.md`**: 
   - You correctly implemented the `KitGhost` mascot (0.06 opacity) and the `Curves.easeOut` transitions in `login_screen.dart` and `sign_up_screen.dart`.
   - You also updated `LumiButton`, `LumiSecondaryButton`, and `LumiTextAction` with the standardized "drifting" (ease-out) animations.
   - However, these were NOT checked off in `midterm-polish-tasks.md`. Only the first sub-task "Layout" was checked.
   - Please ensure ALL sub-tasks that you completed are checked off in the main task list.

3. **Inconsistent Naming**: In `lib/features/auth/login_screen.dart`, you imported `../../core/colors.dart` which seems to define `LumiColors`. In other files, it's often imported from `theme.dart`. Please ensure the project's token structure is consistent.
