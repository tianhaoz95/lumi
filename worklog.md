Task: Confirm FloatingNavBar is a pill shape, does not span full width, and uses glassmorphism (design/roadmap/phase-5-aurora.md — 1.2.2).

Plan (step-by-step):
1. Search the codebase for `FloatingNavBar`, `floatingNavBar`, `FloatingNav`, or bottom navigation implementations.
2. Open the file(s) that implement the bottom navigation.
3. Implement a FloatingNavBar widget with these properties:
   - Pill shape (rounded rectangle with large radius, e.g., BorderRadius.circular(9999) or 16+)
   - Does not span full width: centered, max width ~ 640dp or 80% of width on small screens
   - Glassmorphism: uses BackdropFilter(blur) and a semi-transparent surface color (surface-container-lowest @ 70% opacity)
4. Replace usages of existing full-width BottomNavigationBar with the new FloatingNavBar or wrap current widget where appropriate.
5. Run Flutter analyzer/tests (if available) and ensure no errors.
6. Add a widget test (if test infra present) to assert the FloatingNavBar is not full width and has BackdropFilter in its widget tree.
7. Verify the visual behavior by ensuring code compiles (flutter build or flutter analyze). Commit changes.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- New or modified widget file (e.g., `lib/shared/widgets/floating_nav_bar.dart`) implementing `FloatingNavBar` with pill shape and glassmorphism.
- All references to bottom nav in the app use or can accept the new FloatingNavBar (no runtime errors on `flutter analyze`).
- A widget test exists asserting the pill shape and presence of `BackdropFilter` (if tests present). If tests are not present, `flutter analyze` exits with code 0.
- `design/roadmap/phase-5-aurora.md` task 1.2.2 remains unchecked until reviewer verifies; worklog contains the implementation details for reviewer validation.

Notes:
- Do not delete worklog.md in repo. The reviewer will mark the task done after verification.
