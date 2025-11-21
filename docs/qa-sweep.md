# QA Sweep - Local Dev Stack

## Environment
- Database: `DATABASE_URL=postgres://postgres:postgres@127.0.0.1:54322/postgres` (set `PGOPTIONS='-c role=supabase_admin'` so the canonical user can rebuild schemas); `supabase_admin` password is `postgres`.
- Supabase local: `SUPABASE_URL=http://127.0.0.1:54321`, anon key from `apps/web_pwa/.env.local` and `apps/b2b_flutter/assets/config/app_config.json`.
- PWA data mode: `APP_DATA_MODE=local` for normal runs; when it is not `local`, JSON APIs return `503` with `{ error: { code: "LOCAL_MODE_REQUIRED", ... } }`.
- pnpm: use `PNPM_EXEC="node $NVM_DIR/versions/node/v20.18.2/lib/node_modules/pnpm/bin/pnpm.cjs"` to avoid corepack signature errors.

## Test Commands
- Flutter formatting/analyzer/tests:
  - `dart format --set-exit-if-changed apps/b2b_flutter packages/dart/offline_toolkit`
  - `flutter analyze`
  - `flutter test --reporter=expanded`
- Supabase:
  - Deno: `cd supabase/functions && deno test --allow-env`
  - SQL RLS: `cd supabase/tests && PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f setup_test_db.sql` then run each of `rls_regressions.sql`, `rls_assertions.sql`, `orders_submit_test.sql`, `pricing_rls_test.sql`, `payment_events_rls_test.sql`, `price_import_effects.sql`.
  - Typegen: `DATABASE_URL=... PNPM_EXEC=... ./.ci/guard-typegen-ts.sh` (regenerates `apps/web_pwa/lib/generated/supabase.types.ts`).
- PWA: `PNPM_EXEC=... pnpm -C apps/web_pwa lint`, `pnpm -C apps/web_pwa typecheck`, `pnpm -C apps/web_pwa test`.

## Notable Changes
- Local-mode enforcement now returns consistent JSON errors with status `503`; tests cover the shape (`apps/web_pwa/lib/local-mode.ts`, `apps/web_pwa/tests/api-local-mode.test.ts`).
- `.ci/guard-typegen-ts.sh` requires `DATABASE_URL`, supports `PNPM_EXEC`, and defaults to the safe dev DB.
- `tsconfig.tsbuildinfo` is ignored and removed from tracking to avoid dirty trees after typecheck.
- Supabase schema now grants `supabase_admin` to `postgres` and `supabase_storage_admin` to `supabase_admin` so QA scripts can reset schemas with the canonical `DATABASE_URL`.

## Manual/Follow-up Checks
- Auth parity: create a user in Flutter and confirm Supabase session works in the PWA (same URL/anon key), including password reset; inspect JWT claims for `role` and `company_id`.
- Offline toolkit (Flutter): verify create/update/delete while offline replays correctly on reconnect.
- Realtime expectations: PWA catalog/cart/orders stay local-only (no realtime sync when `APP_DATA_MODE` is not `local`), while Flutter uses Supabase realtime + RLS.
- Service-role keys stay server-side only (Edge functions); storefront flows rely on anon + local data.
