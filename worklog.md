Task: 1.2.1 — Glassmorphism TopAppBar verification and enforcement

Objective:
Confirm TopAppBar on all screens uses BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20)) with surface-container-lowest at 70% opacity. If missing, implement/update the TopAppBar component to use this pattern and update screens to reference it.

Planned steps:
1. Search the codebase for existing TopAppBar / AppBar implementations and any BackdropFilter usage.
2. Create or update a single shared `LumiTopAppBar` (or `TopAppBar`) widget in `lib/core/widgets/` that wraps an AppBar with a BackdropFilter(ImageFilter.blur(sigmaX:20,sigmaY:20)) and a semi-transparent background color (`LumiColors.surfaceContainerLowest.withOpacity(0.7)`).
3. Replace usages of raw `AppBar` / hardcoded TopAppBar with the shared widget across screens.
4. Run Flutter analyzer / tests (if present) to ensure no errors.
5. Verify code edits compile (run `flutter analyze` or `flutter test` if available). If Flutter tool is not present in CI, ensure Dart code compiles via static checks.

Verifiable deliverables:
- File `worklog.md` exists (this file).
- A new/updated widget file exists at `lib/core/widgets/lumi_top_app_bar.dart` containing `LumiTopAppBar` implementing BackdropFilter with sigmaX/Y = 20 and background color at 70% opacity.
- No remaining direct `BackdropFilter` usages with different sigma values for TopAppBar (grep confirms or updated occurrences).
- All screens that previously used a TopAppBar now import and use `LumiTopAppBar` (grep for `LumiTopAppBar` shows references).
- Project compiles or `flutter analyze` (if available) completes without errors.

Notes:
- If the project does not contain Flutter source files or the expected widget locations, adapt by creating the widget in the best matching module under `lib/` and update obvious TopAppBar usages.
- Do not delete files; only add or modify minimal files necessary.

Reviewer checklist (how to verify):
- Open `lib/core/widgets/lumi_top_app_bar.dart` and confirm BackdropFilter(sigmaX:20,sigmaY:20) and background color opacity 0.7.
- Run `rg "LumiTopAppBar"` or `grep -R "LumiTopAppBar" -n` to see usages.
- Confirm `flutter analyze` (or `dart analyze`) returns no errors.
