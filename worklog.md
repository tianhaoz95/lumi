Task: Verify grain texture does not impact frame rate (Phase 5, task 1.3.3)

Planned steps:
1. Locate the AtmosphericBackground and grain implementation in the codebase and confirm how it is rendered (SVG vs CustomPainter).
2. Run existing widget tests covering the grain overlay to ensure the widget is present and repaint boundaries exist.
3. Create a small performance capture script (scripts/perf/run_grain_perf.sh) that runs a profile build and records a timeline while scrolling and animating the screen with grain enabled and disabled.
4. Run the widget tests. If possible, run the profile capture script to produce a timeline (artifacts/grain_perf.timeline).
5. Inspect results (test pass status and timeline file presence). If any jank is observed, propose minimal mitigations (limit grain detail, wrap in RepaintBoundary, reduce particle count) and implement them.
6. Report findings and mark the roadmap task done when performance is validated or mitigations applied and re-tested.

Verifiable deliverables:
- worklog.md exists (this file).
- The following widget tests run and exit with code 0:
  - test/grain_repaint_test.dart
  - test/widgets/atmospheric_background_test.dart
- A performance script exists at scripts/perf/run_grain_perf.sh which documents how to capture a profile and produces artifacts/grain_perf.timeline when run.
- If a mitigation was required, a small code change is present and corresponding tests still pass.

Notes:
- The repo already contains AtmosphericBackground and grain assets (design/assets/grain.svg) and widget tests. The plan is to run those tests and create an automated profile script. If CI environment lacks Flutter for running profile captures, the script is still a verifiable artifact and tests should still run in CI where Flutter is available.

Generated-by: Copilot agent

Results:
- Widget tests run: test/grain_repaint_test.dart, test/widgets/atmospheric_background_test.dart
  - All tests passed (exit code 0).
- Perf script created: scripts/perf/run_grain_perf.sh (executable). To capture a timeline, run on a physical device: ./scripts/perf/run_grain_perf.sh <device-id>
- Automated timeline capture was not executed here (requires attached device). The script documents the steps and will produce artifacts/grain_perf_trace.json (best-effort) when run.

Completed-at: 2026-04-12T21:56:29Z
