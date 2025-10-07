# Test Summary — 2025-10-07

## Flutter (`apps/b2b_flutter`)
- Command: `./.flutter_local/bin/flutter --no-version-check test --coverage -r expanded`
- Result: **PASSED** (env: `HOME=$PWD`, `PUB_CACHE=/Users/shachar/.pub-cache`, `FLUTTER_SUPPRESS_ANALYTICS=true`, `--no-pub --no-dds`, escalated loopback sockets)
- Previous failures addressed:
  - `test/lists/saved_lists_states_test.dart` — added `saved_lists_error_state` key.
  - `test/features/support/presentation/support_tickets_page_test.dart` — promoted keyed assertions and exposed matching keys in UI.
  - `test/promotions/promotions_card_test.dart` — preserved injected callbacks.
  - `test/quick_order/*` — harness now waits for catalog provider and forces review stage.
  - `test/orders/checkout_page_test.dart` — stubbed checkout form/pricing providers so submit CTA renders.

## Web PWA (`apps/web_pwa`)
- Command: `npx --yes vitest run`
- Result: **BLOCKED** — Vitest requires `jsdom`. Run `npm install` (or ensure dev deps are locally installed) before re-running tests.

## Notes
- `test/test_harness.dart` now accepts untyped override lists; callers may continue to pass `Override` instances without change.
- Quick order helpers synchronise provider futures so catalog gating assertions can rely on deterministic state.
