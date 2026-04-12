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
1. **Button Taps Animations Missing**: The "Transitions" task requires button taps to use "drifting" (ease-out) animations. Currently, `LoginScreen` and `SignUpScreen` use standard `ElevatedButton` which lacks these animations. You should use `LumiPrimaryButton` (from `lib/shared/widgets/lumi_buttons.dart`) or implement a similar "drifting" effect on tap. Note that `LumiButton` currently uses `Curves.easeInOut`; ensure you use `Curves.easeOut` to match the "drifting" requirement.
2. **Themed Buttons Not Used**: Section 2.2 of `midterm-polish-tasks.md` specifies that `LumiPrimaryButton` should be implemented and used. The auth screens still use `ElevatedButton`.
3. **ForgotPasswordScreen Polish**: `lib/features/auth/forgot_password_screen.dart` was not updated to match the "Glacial Sanctuary" design. It lacks the `KitGhost` mascot, the `AnimatedContainer` for focus transitions, and still uses a standard `Card` and `ElevatedButton`.
4. **Unmarked Sub-tasks**: You have successfully implemented the `KitGhost` mascot (0.06 opacity) in `LoginScreen` and `SignUpScreen`, but the "Mascot" sub-task in `midterm-polish-tasks.md` is still marked as `[ ]`. Similarly, "Transitions" is unmarked, likely because it's incomplete for button taps.
5. **Code Style**: Ensure `LumiPrimaryButton` is used consistently across all auth screens for primary actions.
