# Monorepo Restructure Plan — א.שחר Marketplace

## Target Layout

```
apps/
  b2b_flutter/            (migrated from app/)
  web_pwa/                (migrated from ashachar-commerce/)
packages/
  dart/design_system/     (extracted from app/lib/src/design_system)
  dart/offline_toolkit/   (Hive cache, delta sync, queue primitives)
  dart/core_contracts/    (DTOs, Supabase client abstractions)
  ts/web_ui/              (shared React components, OG route)
  ts/supabase-contracts/  (generated types, API surface parity)
supabase/
  sql/                    (schema, policies, patches)
  policies/               (optional split from sql/ if preferred)
  functions/              (edge functions only)
  seeds/                  (bootstrap + fixtures)
  scripts/                (CLI wrappers, migrations, QA)
tools/
  qa/                     (qa-run, sim-run, agent triage)
  snapshots/              (ts-node snapshots, pdf tooling)
  ci/                     (inventory scripts, automation)
docs/
  README.md
  DESIGN.md
  ADRs/, runbooks/, offline.md, RLS matrices
archives/
  *.zip, *.b64, telemetry/log artifacts (kept out of main tree)
```

## Source → Destination Mapping

### Applications
- `app/` → `apps/b2b_flutter/`
  - Preserve Clean Architecture layering (`core → data → presentation`); adjust package name in `pubspec.yaml` only if necessary to avoid import churn.
  - `app/docs/` assets migrate to `docs/screens/` with cross-links updated.
  - `app/supabase/` removed once consumers point to `supabase/`.
- `ashachar-commerce/` → `apps/web_pwa/`
  - Flatten `app/`, `components/`, `lib/`, `data/` structure beneath the new root unchanged.
  - `ashachar-commerce/supabase/` removed after alignment with `supabase/`.

### Shared Packages
- `app/lib/src/design_system/` → `packages/dart/design_system/lib/`
  - Publish as local path dependency; update `apps/b2b_flutter/pubspec.yaml` to reference `packages/dart/design_system`.
- `app/lib/src/offline/` (cache, queue, sync, workmanager glue) → `packages/dart/offline_toolkit/lib/`
  - Federate any Drift table definitions and Delta sync logic to keep offline-first primitives reusable.
- `app/lib/src/core/*` DTOs that are also used by edge functions (e.g., `order_splitter`, `notify_status_change`) → `packages/dart/core_contracts/lib/`
  - Mirror Supabase JSON contracts; plan to generate TypeScript equivalents.
- `ashachar-commerce/app/api/og/route.tsx` + `app/api/og/route.tsx` → `packages/ts/web_ui/og/`
  - Update both apps to import via `@ashachar/web-ui/og`.
- `supabase gen types` outputs → `packages/dart/core_contracts` and `packages/ts/supabase-contracts`
  - Automate via CI so both Flutter and Next clients consume identical database types.

### Supabase
- Keep `supabase/` as the single source of truth.
- Merge duplicated files (`app/supabase/*`, `ashachar-commerce/supabase/*`) into the authoritative tree and delete embedded copies.
- Promote `supabase/sql/policies.sql` & `supabase/sql/policies_public.sql` into `supabase/policies/` if a finer split is preferred; ensure docs/RLS matrix stays in sync.
- Relocate `staging/supabase/` overrides into `supabase/environments/staging/` (or keep under `supabase/overrides/staging/`) to align structure and simplify diffs.

### Tooling & Scripts
- Consolidate shell helpers:
  - `app/scripts/` → `tools/qa/`
  - `scripts/` (root) → `tools/ci/`
  - `ashachar-commerce/scripts/` (snapshots/import) → `tools/snapshots/`
  - `supabase/scripts/` → `supabase/scripts/` (unchanged) but expose via Makefile/justfile in repo root.
- Deduplicate `codex_inventory*.sh` versions; keep the newest in `tools/ci/`.

### Documentation, Artifacts, Archives
- Merge `app/docs/` with root `docs/` — categorize Flutter-specific guides under `docs/clients/flutter/`.
- Move `.zip` and `.b64` snapshots to `archives/` (or publish to GitHub Releases) to keep working tree lean.
- Ensure `docs/offline.md` references new package names and directory locations.

## Dependency & Import Impact Map

| Producer → Consumer | Current Location | Future Location | Import Impact |
| --- | --- | --- | --- |
| Flutter design system widgets → Flutter presentation layer | `app/lib/src/design_system/*` | `packages/dart/design_system/lib/*` | Update imports to `package:design_system/...`; add path dependency in `apps/b2b_flutter/pubspec.yaml`. |
| Offline cache & queue → Flutter data layer | `app/lib/src/offline/*` | `packages/dart/offline_toolkit/lib/*` | Replace `package:ashachar_marketplace/src/offline/...` with `package:offline_toolkit/...`; export migration utilities for tests. |
| Supabase DTOs shared with Edge functions | `app/lib/src/data/models/*` & TS inline types | `packages/dart/core_contracts`, `packages/ts/supabase-contracts` | Generate via `supabase gen types dart/typescript`; update imports to reference generated modules. |
| OG image route (Next/Flutter Web) | `app/api/og/route.tsx` & `ashachar-commerce/app/api/og/route.tsx` | `packages/ts/web_ui/og/route.tsx` | Configure Next/Flutter web builders to import from `@ashachar/web-ui/og/route`; remove duplicate copies. |
| Supabase client bootstrap | `app/supabase/functions/_shared/client.ts` & `supabase/functions/_shared/client.ts` | `supabase/functions/_shared/client.ts` (single source) | Edge functions import remains `../_shared/client`; CI ensures no secondary copies exist. |
| QA shell scripts | `app/scripts/*.sh`, `scripts/codex_inventory_v2.sh` | `tools/qa/*.sh`, `tools/ci/codex_inventory.sh` | Update references in docs & CI workflows (`.github/workflows/*`) to new tool paths. |
| Staging schema references | `staging/supabase/sql/*.sql` | `supabase/environments/staging/sql/*.sql` | Update deployment scripts to read from new path; align docs/runbooks. |

_Guiding principle_: preserve `package:ashachar_marketplace` import prefix inside Dart unless pubspec `name` changes; if renamed, run `dart fix --apply` or scripted `rg`/`sd` replace scoped to `apps/b2b_flutter/lib`. For TypeScript, prefer `tsconfig.paths` aliases (`@ashachar/web-ui`, `@ashachar/supabase-contracts`) to avoid deep relative paths.

## Execution Steps

1. **Preparation**
   - Create feature branch `chore/monorepo-structure`.
   - Freeze Supabase migrations; export latest schema (`supabase db pull --include-policies`).
   - Snapshot existing CI pipeline status.
2. **Create Scaffold**
   - Add `apps/`, `packages/`, `supabase/`, `tools/`, `docs/`, `archives/` directories.
   - Introduce root `justfile` or `Makefile` orchestrating build/test commands across apps.
3. **Supabase Consolidation**
   - Move authoritative files to `supabase/`; delete duplicates under `app/supabase/` and `ashachar-commerce/supabase/`.
   - Update each client’s `.env` / config to point to shared `supabase/config.toml`.
   - Regenerate Dart/TS types into `packages/*/supabase-contracts`.
   - Run RLS regression tests (psql fixtures + Supabase CLI) before/after diff.
4. **Flutter App Migration**
   - Relocate `app/` → `apps/b2b_flutter/`.
   - Update workspace scripts (`tools/qa/qa-run.sh`, CI workflows) with new path.
   - Extract `design_system`, `offline`, and shared DTOs into Dart packages; wire `pubspec.yaml` path dependencies.
   - Run `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web`.
5. **Next.js App Migration**
   - Move `ashachar-commerce/` → `apps/web_pwa/`.
   - Configure root `package.json` (or npm workspaces) if multi-app install is desired; otherwise, keep app-local `package.json`.
   - Relocate OG route + shared UI utilities into `packages/ts/web_ui`; update imports via `tsconfig.json`.
   - Run `npm install`, `npm run lint`, `npm test`, `npm run build`.
6. **Tooling Consolidation**
   - Relocate shell & ts-node scripts under `tools/`; adjust CI references.
   - Move snapshot PNGs/logs to `archives/` (or publish to artifacts).
   - Update `docs/runbooks` with new script locations.
7. **Documentation & Metadata**
   - Refresh `README.md` and `docs/` index to describe new layout.
   - Update ADRs if architecture decisions change (e.g., new package boundaries).
   - Align `docs/offline.md` and `docs/RLS-matrix.md` with new module names.
8. **CI & Quality Gates**
   - Update GitHub Actions to run Flutter/Next/Supabase jobs from new paths.
   - Add lint/test steps for new shared packages (Dart `melos` or custom script, TS using `npm run lint`).
   - Ensure `archives/` excluded via `.gitignore` or handled via Git LFS.
9. **Final Verification**
   - Run full QA script `tools/qa/qa-run.sh`.
   - Execute Supabase migration dry run `supabase db diff --use-migra`.
   - Smoke-test production builds (`flutter build web`, `npm run serve:prod`).
   - Update MANIFEST/BUILD_COMMANDS to reflect new structure.

## Validation & Regression Commands

| Area | Command | Purpose |
| --- | --- | --- |
| Flutter analyze/tests | `cd apps/b2b_flutter && flutter clean && flutter pub get && flutter analyze && flutter test --coverage` | Ensure Clean Architecture layers intact and offline modules compile. |
| Flutter web build | `cd apps/b2b_flutter && flutter build web --release` | Validate admin web deployment after path changes. |
| Next.js quality | `cd apps/web_pwa && npm install && npm run lint && npm test && npm run build` | Confirm storefront/admin PWA remains healthy. |
| Shared Dart packages | `dart pub publish --dry-run` (per package) or `melos bootstrap && melos test` | Validate package boundaries, ensure no unintended imports. |
| Shared TS packages | `cd packages/ts && npm install && npm test` | Test OG route + shared utilities. |
| Supabase schema | `cd supabase && supabase db lint && supabase db reset --env staging` | Verify unified schema + staging overrides. |
| RLS regression | `psql -f docs/tests/rls_regressions.sql` (or custom harness) | Ensure tenant isolation still enforced post-move. |
| Offline queue integration | `cd apps/b2b_flutter && flutter test test/offline/**/*_test.dart` | Confirm offline primitives intact. |

## Risks & Mitigations

- **Import Drift**: Use `rg` to detect stale `package:ashachar_marketplace/src/...` imports after extraction; add CI lint to forbid direct cross-layer imports.
- **Supabase Schema Divergence**: Run diffs between `supabase/sql` and `staging` before deleting staging copies; document intentional deltas.
- **Dependency Explosion**: Consider `melos` or Flutter `dart_tool/package_config.json` management to keep path dependencies tidy.
- **CI Cache Bust**: Clearing `node_modules` and Flutter build caches may lengthen first CI run; prime caches post-migration.
- **RTL & Responsive Validation**: After moving assets, run existing golden tests plus manual RTL smoke (per ADR-004) to ensure layout assets resolve correctly.

## Follow-Up Items

1. Automate Supabase type generation into shared packages (Dart & TS) during CI.
2. Add unit tests for newly formed packages (e.g., offline toolkit, design system).
3. Document new workspace commands in `docs/runbooks/deploy.md`.
4. Archive historical `.zip` bundles outside the repository to keep clone size manageable.
