Task: Ensure AtmosphericBackground orbs are present on Login, Sign Up, Forgot Password, Home, and Dashboard screens (roadmap item 1.3.2)

Planned steps:
1. Search the repo for existing `AtmosphericBackground`, `Atmospheric`, or `Orb` widgets and for the five target screens.
2. If an `AtmosphericBackground` widget exists, audit its API and ensure it supports toggling/placing orbs on specified screens; update usages to include it on the five screens.
3. If it does not exist, create `lib/widgets/atmospheric_background.dart` implementing a lightweight, testable Flutter widget that draws animated orbs using `CustomPainter` and simple `AnimationController` logic.
4. Add/modify the five screen files to include `AtmosphericBackground` as a top-layer background widget. If those screen files don't exist, add placeholder screens in `lib/screens/` that import and use the widget (safe, non-breaking additions).
5. Add a widget test `test/widgets/atmospheric_background_test.dart` that instantiates the widget and asserts it renders orbital layers (via Finder for a key).
6. Run existing project tests (if present) and ensure the new test passes.
7. Update `design/roadmap/phase-5-aurora.md` marking item 1.3.2 done after verification.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- File `lib/shared/widgets/atmospheric_background.dart` exists and defines `AtmosphericBackground`.
- The five target screen files include `AtmosphericBackground` (updated in-place):
  - `lib/features/auth/login_screen.dart`
  - `lib/features/auth/sign_up_screen.dart`
  - `lib/features/auth/forgot_password_screen.dart`
  - `lib/features/home/home_impl.dart`
  - `lib/features/dashboard/dashboard.dart`
- A widget test at `test/widgets/atmospheric_background_test.dart` that pumps the widget and finds a Container with Key('atmospheric-orbs').
- Running `flutter test` (if Flutter tests are present) executes the new test and it passes (exit code 0). If Flutter tooling is not present in CI, tests at least exist in the repo.

Notes:
- Keep implementation minimal and dependency-free (no external Lottie) so it remains buildable in this pre-implementation repo.
- Do not remove or modify unrelated files.
