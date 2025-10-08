# Test Summary — 2025-10-08

## Flutter (`apps/b2b_flutter`)
- Command: `HOME=$PWD PUB_CACHE=/Users/shachar/.pub-cache FLUTTER_SUPPRESS_ANALYTICS=true ./.flutter_local/bin/flutter --suppress-analytics --no-version-check test --no-pub --no-dds --coverage -r expanded | tee codex/flutter_full_test.log`
- Before: **PASS 0 / FAIL 74** — identical sandbox socket denial reported on 2025-09-20.
- After: **PASS 0 / FAIL 74** — no code paths executed; `flutter_tester` still cannot bind to localhost (errno 1). Coverage artefacts untouched.
- Key follow-ups: tests must run on a host with loopback socket access or via approved remote runner.

## Web PWA (`apps/web_pwa`)
- Command: `npx vitest run | tee codex/vitest_full_test.log`
- Before: **BLOCKED** — prior run required `jsdom` install.
- After: **PASS 29 / FAIL 0** — vitest completes locally; legal page suite logs sandbox skip for port binding but does not fail.
- Key follow-ups: none; keep pdf-lib font guardrails ready if upstream font embedding test regresses.
