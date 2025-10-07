# Stabilize Flutter tests + test harness + fakes; archive duplicates

## Checklist
- [x] Ensure `makeTestApp` accepts mixed override types without Riverpod `Override` import.
- [x] Harden quick-order harness to wait for catalog fakes and force review stage, fixing gating widget tests.
- [x] Restore widget keys for saved lists, support tickets, and checkout CTA flows so keyed assertions succeed.
- [x] Respect injected promotion callbacks instead of always routing to `/catalog`.
- [x] Provide deterministic checkout form/pricing stubs for approvals and pricing tests.

## Testing
- Flutter: `HOME=$PWD PUB_CACHE=/Users/shachar/.pub-cache FLUTTER_SUPPRESS_ANALYTICS=true ./.flutter_local/bin/flutter --no-version-check test --no-pub --no-dds --coverage -r expanded`
- Web PWA: `npx --yes vitest run` (blocked until local `npm install` provisions `jsdom`)
