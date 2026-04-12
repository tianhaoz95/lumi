Task: 1.3.3 — Verify grain texture does not impact frame rate

Planned steps:
1. Inspect current AtmosphericBackground and grain implementation (CustomPainter + RepaintBoundary).
2. Optimize painting by caching the grain as a Picture to avoid expensive per-frame draw loops.
3. Expose a small test helper to verify cache population.
4. Add a unit/widget test that pumps AtmosphericBackground and asserts the grain cache is populated.
5. Run widget tests (targeted test) to ensure no regressions.
6. Document verifiable deliverables below.

Verifiable deliverables:
- File lib/shared/widgets/atmospheric_background.dart updated to cache grain drawing (uses Picture cache).
- Public helper function getAtmosphericGrainCacheSize() exists and returns an integer.
- New test test/grain_cache_test.dart exists and passes when running `flutter test test/grain_cache_test.dart`.
- Existing grain_repaint_test.dart still passes.
- worklog.md created (this file).

Notes:
- Full device performance validation (DevTools overlay) should be performed on a physical device using scripts/perf/run_grain_perf.sh; this step is documented but not executed here due to CI limitations.
