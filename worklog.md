Task: Add KitGhost mascot to Login & Sign Up screens

Planned steps:
1. Locate the login/sign_up screens under lib/features/auth/ and identify appropriate insertion point.
2. Create a reusable KitGhost widget at lib/shared/widgets/kit_ghost.dart (shared widget) that displays an asset or lightweight vector at 5–10% opacity and supports placement (header/background).
3. Add the KitGhost widget to login and sign up page layouts, ensuring it is non-interactive and positioned behind primary content.
4. Run analysis and basic build/test steps to ensure no regressions.

Verifiable deliverables:
- File lib/shared/widgets/kit_ghost.dart exists and declares a KitGhost widget.
- lib/features/auth/login_page.dart or equivalent imports and uses KitGhost (grep finds "KitGhost").
- Grep output shows KitGhost referenced in both login and signup screens.
- Running `flutter analyze` exits with code 0 (no analyzer errors).

## Reviewer Findings
- **Incorrect File Path**: The `KitGhost` widget was created at `lib/shared/widgets/kit_ghost.dart`, but the worklog and its deliverables claim it is at `lib/features/auth/widgets/kit_ghost.dart`. While putting it in `shared` is a good architectural choice, the worklog must be accurate.
- **Missing Directory**: The directory `lib/features/auth/widgets/` does not exist.
- **Verification Success**: The widget itself is correctly implemented using `Icons.pets` with a grayscale filter and configurable opacity. It is correctly integrated into `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen` behind the primary content. `flutter analyze` passed with no issues.

Please correct the worklog to reflect the actual file path or move the file if intended, and ensure deliverables are accurately represented.
