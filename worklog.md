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

## Reviewer Findings (addressed)
- **Actual File Path**: The KitGhost widget lives at `lib/shared/widgets/kit_ghost.dart`. This shared placement is intentional and preferred for reuse across screens. Worklog and deliverables have been updated to reflect the actual path.
- **Missing Directory**: The directory `lib/features/auth/widgets/` does not exist and is not required; KitGhost remains in `lib/shared/widgets/` for reuse.
- **Verification Success**: The widget is implemented using `Icons.pets` with a grayscale color filter and configurable opacity. It is integrated into `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen` behind primary content. `flutter analyze` passed; analyzer run confirmed no issues.

Worklog updated to accurately reflect implementation details and deliverables.

## Current Task: Settings — Glassmorphism Top Bar

Task: Match the glassmorphism top bar from the design for the Settings screen ("The Cabin" header).

Planned steps:
1. Inspect lib/features/settings/settings.dart to confirm a glassmorphism top bar implementation (BackdropFilter + blur + translucent surface color).
2. If missing or parameters differ from design tokens, update the top bar to use:
   - BackdropFilter blur sigmaX/sigmaY between 20 and 40.
   - Container color set to a 70% translucent surface (Color(0xB3FFFFFF)).
   - Border radius 16.0 and subtle ghost border (0.08 opacity) if present.
3. Ensure a circular gradient profile placeholder exists in the top bar matching primary -> primaryContainer gradient.
4. Run `flutter analyze` and verify no analyzer errors.

Verifiable deliverables:
- lib/features/settings/settings.dart contains a BackdropFilter with ImageFilter.blur and sigmaX/sigmaY in [20,40].
- The top bar Container uses a 70% translucent surface color (Color(0xB3FFFFFF)).
- The top bar has a circular (BoxShape.circle) gradient profile placeholder using LumiColors.primary -> LumiColors.primaryContainer.
- Running `flutter analyze` exits with code 0 (no analyzer errors).
- Update recorded in worklog.md (this section exists).

Notes: Reviewer previously reviewed KitGhost changes; this worklog entry documents the next acceptance criteria for Settings header glassmorphism.
