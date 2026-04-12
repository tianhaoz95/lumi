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
1. **Analyzer Failures**: `flutter analyze` currently exits with code 1. While many are deprecated warnings, there is a specific unused import in `lib/shared/widgets/lumi_buttons.dart` (`'../../core/theme.dart'`) which was likely introduced during the implementation of `LumiPrimaryButton`. This must be fixed to satisfy the "exit code 0" requirement.
2. **Unmarked Sub-tasks**: You have successfully implemented the `KitGhost` mascot (0.06 opacity) and focus animations (using `AnimatedContainer` with `Curves.easeOut`) in `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen`. However, the **Mascot** and **Transitions** sub-tasks in `midterm-polish-tasks.md` are still marked as `[ ]`. These should be marked as `[x]` once you are confident they are complete.
3. **Incomplete Button Transitions**: The "Transitions" sub-task requires button taps to use "drifting" (ease-out) animations. While `LumiPrimaryButton` (via `LumiButton`) has this animation, the following elements lack it:
   - `LumiSecondaryButton` (in `lib/shared/widgets/lumi_buttons.dart`) uses standard `InkWell` without the `AnimatedScale` found in `LumiButton`.
   - `TextButton` used in `LoginScreen` and `SignUpScreen` (e.g., for navigation to signup/login) doesn't have the "drifting" effect. Consider wrapping these in a widget that provides the `LumiButton` animation or standardizing them.
4. **ForgotPasswordScreen Verification**: While you have polished `ForgotPasswordScreen` to match the "Glacial Sanctuary" design (it has the mascot, focus animation, and themed button), ensure that all auth-related screens are consistent.
5. **Test Failures**: `test/login_screen_test.dart` is currently failing to compile due to a constant evaluation error in the `google_fonts` package. While this might be an environment-related issue, please investigate if any of your theme changes or font usages contributed to this or if the test itself needs updates to account for the new layout.
