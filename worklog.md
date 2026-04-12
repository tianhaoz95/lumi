Task: Implement LumiSecondaryButton (Glassmorphism) — midterm polish

Plan (step-by-step):
1. Locate existing button implementations and theme files (search for "LumiPrimaryButton", "button", and theme files under lib/).
2. Add a new widget `LumiSecondaryButton` in `lib/shared/widgets/` or next to existing button widgets following repo structure; style it to use glassmorphism: white at 40% opacity background with a 12px backdrop blur and rounded pill shape.
3. Wire the button into theme or examples where appropriate (add a small usage example in `lib/core/theme.dart` or a demo screen if one exists).
4. Run available Flutter analyzer or tests (make test or flutter analyze) to ensure no errors.
5. Run `flutter build apk` (or `make test` if configured) if CI/build scripts exist, or at minimum `flutter analyze` and `flutter test` if present.

Verifiable deliverables:
- File `lib/shared/widgets/lumi_buttons.dart` exists and defines `LumiSecondaryButton` class (the project groups buttons together in this file).
- `LumiSecondaryButton` uses a translucent white background (opacity 40%) and backdrop blur of 12px (uses `BackdropFilter` / `ImageFilter.blur`).
- `LumiSecondaryButton` has pill shape (default radius 9999.0) and accepts `onPressed`, `child`, `padding` parameters.
- Static checks: confirmed via source inspection that blur sigma is 12.0 and background color uses `Colors.white.withOpacity(0.40)`.
- Environment note: Attempted to run `flutter analyze` and `dart analyze` in CI environment but the analysis server failed with "Too many open files (errno = 24)". Commands run:
  - `flutter analyze --no-pub` (failed with OS Error: Too many open files)
  - `flutter analyze lib --no-pub` (failed with OS Error: Too many open files)
  - `dart analyze lib/shared/widgets/lumi_buttons.dart` (failed with same error)
  Saved analyzer output snippets are available in the agent run logs.

Alternative verifiable step for reviewer (local):
- Run `flutter analyze` locally to confirm no analyzer errors (environment limitation prevented in-container analysis).
- Inspect `lib/shared/widgets/lumi_buttons.dart` to verify the three key properties above.

Notes:
- Do not delete or overwrite other files. Keep changes minimal and targeted to add the new widget and any necessary exports.
- Reviewer will verify by checking the file and running analyzer/tests locally if desired.
