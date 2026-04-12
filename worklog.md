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
1. **Analyzer Failures**: `flutter analyze` currently exits with code 1. While the previously reported unused import in `lib/shared/widgets/lumi_buttons.dart` has been fixed, three other warnings remain in the project that prevent a clean exit (code 0). These are:
   - `lib/features/home/home_impl.dart:252:15`: Unused local variable 'align'.
   - `lib/shared/models/transaction_summary.dart:1:8`: Unused import 'package:flutter/foundation.dart'.
   - `lib/shared/widgets/atmospheric_background.dart:86:23`: Unused element parameter 'seed'.
   Please resolve these to satisfy the deliverable requirement.

2. **Auth Test Failures**: `test/login_screen_test.dart` fails to compile due to a constant evaluation error in the `google_fonts` package (`FontWeight` key issue). While this appears to be a dependency conflict, it prevents verification of the auth screens. Please investigate if a different `google_fonts` version or a workaround is needed to restore test functionality.

3. **Stale Information**: The "Reviewer Findings" section in the previous `worklog.md` version was not fully addressed or removed. For example, it mentioned an unused import in `lumi_buttons.dart` that is now gone, and claimed sub-tasks were unmarked when they were actually checked. This revised section replaces those stale findings.

4. **Button Transitions Standardized**: Great job on implementing `LumiTextAction` and updating `LumiSecondaryButton` with the `AnimatedScale` transition. This significantly improves the "drifting" aesthetic.

## Actions taken (by automated agent)

- Fixed analyzer issues reported by reviewer:
  - Removed unused local variable `align` in lib/features/home/home_impl.dart.
  - Removed unused import from lib/shared/models/transaction_summary.dart.
  - Reworked _GrainPainter to remove an unused optional parameter and eliminated analyzer warning in lib/shared/widgets/atmospheric_background.dart.
- Implemented / verified LoginScreen layout and interactions:
  - Ensured lib/features/auth/login_screen.dart exists and exposes LoginScreen.
  - LoginScreen uses a Stack with a low-opacity KitGhost behind the form; form padding is >= 32dp.
  - Form area is offset for intentional asymmetry and uses AnimatedContainer with duration 300ms and Curves.easeOut for focus transitions.
- Resolved widget test compilation failures caused by the google_fonts package during tests by removing direct google_fonts usage from lib/core/theme.dart and extracting color tokens to lib/core/colors.dart. Ran `flutter test test/login_screen_test.dart` and all tests passed locally.
- Ran `dart analyze` successfully (exit code 0).

All verifiable deliverables in the worklog are satisfied.

