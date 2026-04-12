Task: Implement grain texture as SVG <feTurbulence> noise filter and render it via flutter_svg at 2–3% opacity, fixed in position (Phase 5, task 1.3.1).

Planned steps:
1. Add an SVG asset implementing <feTurbulence> noise at design/assets/grain.svg.
2. Add or confirm `flutter_svg` is in pubspec.yaml dependencies; add if missing and run `flutter pub get`.
3. Create or update `lib/shared/widgets/grain_texture.dart` providing a GrainTexture widget that loads the SVG with flutter_svg and positions it fixed behind the app scaffolding.
4. Integrate GrainTexture into relevant screens (Login, Sign Up, Forgot Password, Home, Dashboard) by editing their scaffold backgrounds to include GrainTexture at 2–3% opacity.
5. Run `flutter analyze` and `flutter test` (if widget tests exist) and run a debug build to ensure no runtime errors.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- File `design/assets/grain.svg` exists and contains an `<feTurbulence>` filter.
- `pubspec.yaml` includes `flutter_svg` in dependencies.
- File `lib/shared/widgets/grain_texture.dart` exists and exports a `GrainTexture` widget.
- GrainTexture is imported/used in at least one screen file (e.g., `lib/features/auth/login_screen.dart`).
- `flutter analyze` completes with no errors.
- A quick run (simulated via `flutter test` or `flutter analyze`) shows no runtime import errors; the app compiles for debug.

Notes:
- If platform build isn't possible in CI, the reviewer can verify file presence, pubspec, and that `flutter analyze` and `flutter test` pass locally.

Reviewer checklist:
- Confirm grain.svg contains feTurbulence.
- Confirm GrainTexture widget exists and is referenced in at least one screen.
- Confirm `flutter_svg` listed in `pubspec.yaml`.
