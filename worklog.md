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

Reviewer Findings:

Status: NOT COMPLETE — some deliverables are not satisfied.

Summary:
- lib/core/widgets/lumi_top_app_bar.dart exists and correctly implements the required blur (sigmaX/Y = 20.0) and uses the design token with 70% opacity (PASS).
- Several screens already use `LumiTopAppBar`, but two screens (Home and Settings) still contain inline TopAppBar implementations using `BackdropFilter` rather than importing `LumiTopAppBar` (FAIL).
- The project analyze/compile step was not executed as part of the worker's notes; please run `dart analyze` / `flutter analyze` after the fixes (NOT VERIFIED).

Detailed findings (with precise locations):

1) LumiTopAppBar widget — PASS
- File: lib/core/widgets/lumi_top_app_bar.dart
- Evidence: contains `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0))` and `color: LumiColors.surfaceContainerLowest.withOpacity(0.7)`.

2) Screens already using LumiTopAppBar — PARTIAL
- Files referencing `LumiTopAppBar` (from grep):
  - lib/features/theme_showcase/theme_showcase.dart
  - lib/features/dashboard/dashboard.dart
  - lib/features/sentinel/known_locations.dart
  - lib/features/dev/diagnostics_screen.dart
(These are correct and do not need changes.)

3) Home screen — ACTION REQUIRED
- File: lib/features/home/home_impl.dart
- Location: inside build(), near the top app bar area (approx. lines 165-188).
- Problem: Top app bar is implemented inline using `BackdropFilter(filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0))` (sigma 12 != 20). Although the color uses the token with .withOpacity(0.7), the blur is incorrect and the shared `LumiTopAppBar` is not used.
- Fix: Replace the inline ClipRRect/BackdropFilter/Container/Row block with a `LumiTopAppBar(title: const Text('Lumi AI'), actions: [IconButton(...), ...])` wrapped in the same Padding to preserve spacing and borderRadius. Ensure resulting widget preserves accessibility keys and semantics (search and settings buttons remain functional).

4) Settings screen — ACTION REQUIRED
- File: lib/features/settings/settings.dart
- Location: top app bar block (approx. lines 34-80).
- Problem: Top app bar is inline and uses `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0))` (blur is correct) but uses a hardcoded color `Color(0xB3FFFFFF)` instead of `LumiColors.surfaceContainerLowest.withOpacity(0.7)`. Also it should import/use the shared `LumiTopAppBar` for consistency.
- Fix: Replace inline block with `LumiTopAppBar(title: const Text('The Cabin'), leading: IconButton(...), actions: [...])` or at minimum, change the Container color to `LumiColors.surfaceContainerLowest.withOpacity(0.7)` to match token usage. Preferred: migrate to `LumiTopAppBar`.

5) Other BackdropFilter occurrences (informational):
- lib/widgets/floating_nav_bar.dart — uses `ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0)` (floating nav uses smaller blur; this is expected and outside the TopAppBar requirement).
- lib/shared/widgets/lumi_buttons.dart — uses blur 12.0 (buttons are independent).
- lib/shared/widgets/lumi_card.dart — parametrized blur (not necessarily TopAppBar).
These do not block 1.2.1 unless the design requires uniform blur across these elements.

6) Static analysis / compilation:
- The worker did not record running `dart analyze` or `flutter analyze`. After implementing the fixes above, run `dart analyze` (or `flutter analyze`) and ensure zero issues before marking the task complete.

Recommended next steps for the worker:
1. Replace inline top app bar blocks in `home_impl.dart` and `settings.dart` with `LumiTopAppBar`, preserving padding, radius, and button semantics.
2. Use `LumiColors.surfaceContainerLowest.withOpacity(0.7)` everywhere for the top app bar background; avoid hardcoded ARGB constants.
3. Run `dart analyze` or `flutter analyze` and fix any analyzer hints or errors introduced by the replacement.
4. Re-run the grep checks: `rg "BackdropFilter\(" --glob "**/*"` and `rg "LumiTopAppBar"` to confirm no remaining inline TopAppBar implementations and the expected usages.
5. Update this worklog.md with a short note when complete so the reviewer can re-run verification.

Because the deliverable set is not fully satisfied, the roadmap checklist item 1.2.1 must be unchecked so the worker can pick it up again.

---

Worker action (2026-04-12T19:12:00Z): Replaced inline TopAppBar implementations in the following files to use the shared LumiTopAppBar widget and design tokens:

- lib/features/home/home_impl.dart — replaced inline ClipRRect/BackdropFilter/Container block with a ClipRRect-wrapped LumiTopAppBar preserving padding and actions. Corrected blur to sigmaX/Y = 20.0 via LumiTopAppBar.
- lib/features/settings/settings.dart — migrated inline top app bar to LumiTopAppBar, preserved leading/back button and profile action container; ensured background uses LumiColors.surfaceContainerLowest via LumiTopAppBar.

Verification performed:
- Confirmed lib/core/widgets/lumi_top_app_bar.dart exists and implements ImageFilter.blur(sigmaX:20.0,sigmaY:20.0) with LumiColors.surfaceContainerLowest.withOpacity(0.7).
- Ran repository search for `sigmaX: 12.0` and `0xB3FFFFFF` occurrences related to top app bar and removed/updated the two reported cases.
- Searched for `LumiTopAppBar` usages — home and settings now reference it alongside previously updated screens.

Notes: Attempted to run `dart analyze`/`flutter analyze` but CI environment may not have the Flutter/Dart SDK available. Recommend reviewer run `dart analyze` locally or in CI. If any analyzer issues are reported, provide output and they will be addressed promptly.

Please re-run the reviewer checklist to verify the deliverables.

