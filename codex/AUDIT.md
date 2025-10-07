# א.שחר Marketplace Repository Audit

## Hierarchical Map

```
.
├── app/ (Flutter B2B client & admin shell)
│   ├── lib/
│   │   ├── src/core/ (config, localization, errors, presentation primitives)
│   │   ├── src/data/ (DTOs, repositories, Supabase adapters)
│   │   ├── src/features/ (catalog, orders, pricing, approvals, vendor flows)
│   │   ├── src/offline/ (Hive cache, delta-sync queue, workmanager schedulers)
│   │   └── src/design_system/, analytics/, monitoring/, security/, widgets/
│   ├── assets/ (config JSON, translations, images)
│   ├── integration_test/ & test/ (widget, golden, offline tests)
│   ├── supabase/ (embedded config + functions duplicate of root project)
│   ├── docs/ (screenshots, release notes)
│   └── scripts/ (qa-run, simulator automation, agent triage)
├── ashachar-commerce/ (Next.js 14 storefront & admin tooling)
│   ├── app/ (routing, providers, marketing & vendor pages)
│   ├── components/ & lib/ (React UI, admin access guards, PDF helpers)
│   ├── data/ (seed JSON/CSV for catalogs, vendors, orders)
│   ├── supabase/ (schema/policies duplicate of root project)
│   └── scripts/ (ts-node snapshots, CSV importer)
├── supabase/ (authoritative Supabase project)
│   ├── sql/ (schema, policies, patches, applied snapshots)
│   ├── functions/
│   │   ├── _shared/ (client bootstrap)
│   │   ├── low_stock_scanner/, notify_status_change/
│   │   ├── order_splitter/ (+ utils + tests)
│   │   ├── price_lists_import/
│   │   └── report_generator/
│   ├── seeds/ & seed.sql (tenant bootstrap)
│   └── scripts/ (CLI helpers, migrations glue)
├── staging/
│   └── supabase/ (staging-specific schema & policies overrides)
├── docs/ (ADRs, ERD, RLS matrix, runbooks, offline strategy, UX reports)
├── scripts/ (repo-wide automation, inventory)
├── test/ (offline harness scaffold)
├── .github/, .config/, .dart-tool/ (tooling)
├── logs/, .artifacts/, coverage/, build/ (generated outputs)
├── ashachar_marketplace.zip[.b64], ashachar-commerce.zip (snapshots/backups)
└── README.md, plans (MANIFEST, BUILD_COMMANDS, etc.)
```

_Generated assets (`build/`, `coverage/`, `.dart_tool/`, `.next/`, `node_modules/`, `Pods/`) are omitted from the tree for clarity._

## Project Inventory

| Path | Stack | Purpose | Primary Commands |
| --- | --- | --- | --- |
| `app/` | Flutter & Dart | Multi-tenant marketplace client (mobile & Flutter Web admin) following Clean Architecture layers (`core → data → domain → presentation`), offline-first (Hive, Drift, Workmanager). | `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web` |
| `ashachar-commerce/` | Next.js 14 (TypeScript) | Web storefront/admin PWA, marketing pages, PDF tooling, CSV import helpers; depends on Supabase JS SDK. | `npm install`, `npm run lint`, `npm test`, `npm run build` |
| `supabase/` | SQL & Edge Functions | Authoritative database schema, RLS policies, seeds, and TypeScript edge functions shared by clients. | `supabase db diff`, `supabase db push`, `supabase functions serve <name>` |
| `staging/supabase/` | SQL overrides | Environment-specific schema/policy snapshot for staging validation. | `supabase db reset --env staging` |
| `docs/` | Markdown, media | ERD, RLS matrices, ADRs, runbooks, offline strategy, UX reports/screens. | — |
| `scripts/` | Shell | Monorepo automation (`codex_inventory`, QA runs). | `./scripts/codex_inventory_v2.sh` |
| `.github/workflows/` | YAML | CI pipelines (Flutter tests, Supabase checks, web builds). | GitHub Actions |
| `logs/`, `.artifacts/`, `*.zip` | Mixed | Build/test artifacts and backups; candidates for archival outside main repo. | — |

## Supabase Footprint

- **Schemas & Policies**: Authoritative files in `supabase/sql/` with RLS coverage cross-referenced in `docs/RLS-matrix.md`. Staging overrides diverge; alignment required during restructure.
- **Seeds**: `supabase/seed.sql` mirrors `supabase/seeds/*.sql`; duplicate copies exist under `app/supabase/` and `ashachar-commerce/supabase/`.
- **Edge Functions**: Live under `supabase/functions/` with shared client bootstrap; same sources duplicated in `app/supabase/functions/`.

## Documentation & Operational Assets

- ADRs (e.g., `docs/ADRs/004-admin-flutter-web.md`) codify Flutter-first admin, clean architecture, and offline strategy enforcement.
- Runbooks (`docs/runbooks/*.md`) cover Supabase operations (deploy, rollback, refresh materialized views) and key rotations.
- Offline-first contract captured in `docs/offline.md`; Flutter implementation located in `app/lib/src/offline/`.

## Risks & Debt Pointers

- **Supabase duplication** between `app/supabase/`, `ashachar-commerce/supabase/`, and the root `supabase/` risks schema drift and should be centralized.
- **Web OG route duplication** (`app/api/og/route.tsx` vs `ashachar-commerce/app/api/og/route.tsx`) indicates missing shared web package.
- **Snapshot archives** (`*.zip`, `.b64`) and generated telemetry/log files inflate repo size; move to external artifact store post-archival.
- **Staging schema drift**: `staging/supabase/sql/` diverges from mainline schema; requires diff before migrations are merged.
