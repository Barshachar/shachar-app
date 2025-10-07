# Test Summary — 2025-09-20

## Flutter (`apps/b2b_flutter`)
- Command: `./.flutter_local/bin/flutter --no-version-check test --coverage -r expanded`
- Result: **FAILED** — Flutter analytics attempted to write to `~/.dart-tool/dart-flutter-telemetry-session.json` and the sandbox returned `Operation not permitted`. Code changes include Riverpod listener fixes, unified harness (`test/test_harness.dart`), deterministic widget keys, and fake price services to keep tests offline.
- Follow-up: Re-run the suite in an environment where Flutter can write telemetry (or set `FLUTTER_HOST=https://example.invalid`/`FLUTTER_ANALYTICS_DISABLED=true`) and verify all suites pass.

## Web PWA (`apps/web_pwa`)
- Command: `npm test`
- Result: **FAILED** — Vitest now uses the `jsdom` environment. `jsdom` has been added to `devDependencies`, but the package is not installed inside the sandbox. Install locally (`npm install`) before re-running `npm test`.

## Notes
- Widget tests should be wrapped with `makeTestApp` and can override dependencies via the `overrides` parameter. Use `FakePriceResolutionService` from `test/fakes/` to prevent live Supabase calls.
