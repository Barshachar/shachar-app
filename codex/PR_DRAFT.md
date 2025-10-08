# Stabilize Flutter tests + harness + fakes; archive duplicates

## Checklist
- [ ] Flutter tests green inside sandbox (blocked: loopback socket creation denied).
- [x] Web Vitest run succeeds without regressions.
- [ ] Flutter formatting + analyze clean (local SDK) — `flutter analyze` still reports 3180 legacy issues.
- [ ] Prettier formatting (`apps/web_pwa`) rerun with network-enabled npm.

## Testing
- Flutter: `HOME=$PWD PUB_CACHE=/Users/shachar/.pub-cache FLUTTER_SUPPRESS_ANALYTICS=true ./.flutter_local/bin/flutter --suppress-analytics --no-version-check test --no-pub --no-dds --coverage -r expanded | tee codex/flutter_full_test.log` (fails in sandbox: cannot bind localhost sockets)
- Web PWA: `npx vitest run | tee codex/vitest_full_test.log`
- Flutter analyze: `./.flutter_local/bin/flutter --suppress-analytics --no-version-check analyze --no-pub` (returns 3180 issues from existing backlog)
- Web formatting: `npx prettier -w .` (apps/web_pwa) — run outside sandbox so npm can reach registry if Prettier is not vendored locally.
