# א.שחר Marketplace — Architecture Review (Flutter + Supabase)

## Scope & Context
- **Clients**: `apps/b2b_flutter` (Flutter mobile/web, Riverpod-based) and `apps/web_pwa`.
- **Backend**: Supabase SQL (`supabase/sql`), RLS policies, and Edge Functions under `supabase/functions`.
- **Shared Packages**: `packages/dart/design_system`, `packages/dart/offline_toolkit`, `packages/ts/web_ui`.

This review covers the Flutter architecture (state management, routing, i18n, offline primitives) and the Supabase layer (schema, policies/RLS, Edge functions). Findings feed into TODOs and a proposed feature-first refactor path.

---

## Flutter Architecture Assessment

### Layering & Modules
- The project follows a Clean Architecture-inspired hierarchy (`core → features → presentation`) but **feature files still lean on a monolithic `src/features/...` tree** (e.g., `apps/b2b_flutter/lib/src/features/orders/...`).
- Shared UI and offline primitives were extracted into local packages:
  - `design_system` (`packages/dart/design_system/lib/design_system.dart`) supplies reusable widgets and tokens.
  - `offline_toolkit` (`packages/dart/offline_toolkit/lib/offline_toolkit.dart`) exposes cache, queue, and sync services backed by Hive, Drift, and Workmanager.

### State Management
- **Riverpod 3** is used extensively (`flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`).
- Providers are scattered across feature folders (e.g., cart controller in `features/orders/presentation/cart_controller.dart`). There is no aggregator per feature domain, which complicates DI graph visibility.

### Routing
- Centralized `GoRouter` configuration under `router/app_router.dart` registers every route in one file (~600 lines). This makes feature ownership opaque; dynamic route guards (role-based redirects) live inline and re-compute on each profile change via a `ValueNotifier`.
- Authentication refresh logic is tied to `userProfileProvider`, but there is no per-feature sub-router or declarative shell layout.

### Internationalization
- Custom localization loader (`core/localization/localization.dart`) reads `.arb` files directly. No generated `l10n.dart` or linting of missing keys. Widgets pull strings by key (`translate('ordersTitle')`), but there is no type-safe wrapper or fallback strategy for RTL-specific copy.

### Offline Cache & Queue
- Offline bootstrap is triggered in `AppBootstrap` (`lib/src/app/app_bootstrap.dart:18-31`) which wires `offlineCacheManagerProvider` and `syncSchedulerProvider`.
- Queue/Cache adoption across features varies: catalog, orders, and admin repositories use the toolkit, but some features still call Supabase directly without cached fallbacks (e.g., certain admin detail screens).
- Workmanager jobs exist but scheduling cadence and retry semantics live in code, not configuration.

### Observations
1. **Feature coupling**: UI, state, and data layers of a feature reside in different top-level folders; cross-feature imports are frequent and not enforced by melos/analysis rules.
2. **Router sprawl**: The single router file hampers tree-shaking and is difficult to test in isolation.
3. **I18n gaps**: No tooling ensures keys exist in both `en` and `he`, and translations are not exposed through strongly-typed APIs.
4. **Offline consistency**: Some flows bypass `offline_toolkit`, risking cache misses or inconsistent tenant scoping if providers are accessed before `AppBootstrap` finishes.

---

## Supabase Architecture Assessment

### Schema & SQL
- Primary schema lives in `supabase/sql/schema.sql` plus incremental patches; environment overrides sit in `supabase/environments/staging/`.
- Seeds (`supabase/seed.sql` + `seeds/`) contain demo tenants/vendors seeded per environment.
- **Consistency issue**: there is no automated diff between `schema.sql` and environment-specific `schema.sql`, nor between seeds and application DTOs.

### RLS Policies
- Centralized in `supabase/sql/policies.sql`. RLS enables per-table controls keyed by `auth_company_id()` and `auth_role()`.
- Policies cover admin/vendor/customer personas, but tenant separation relies on helper functions; there is no explicit `tenant_id` column reference on every table (some rely on vendor/customer IDs).
- Negative tests (DO blocks) exist to validate RLS boundaries, yet they only run when the SQL script is executed manually; no automated CI job executes them against a disposable database.

### Edge Functions
- Functions under `supabase/functions/*` share `_shared/client.ts`, but there is no standard contract for DTOs. Some functions re-implement their payload validation, and edge tests exist only for `order_splitter`.
- Deployment and type generation are manual (`supabase/functions deploy`), lacking CI hooks to ensure alignment with Flutter/Next clients.

### Observations
1. **Tenant isolation** depends on convention; without uniform `tenant_id` usage and automated regression tests, regressions can slip in.
2. **Schema ↔ DTO drift**: Flutter models (Freezed classes) and TS types are hand-maintained; no `supabase gen types` integration ensures parity.
3. **Edge Function testing**: Only `order_splitter` has tests; other critical workflows (price lists import, low stock scanner) lack regression coverage.

---

## TODOs
- **TODO A — Feature-first restructuring**
  - Break `apps/b2b_flutter/lib/src/features/**` into **feature packages** (e.g., `packages/dart/feature_orders`) exposing `application`, `domain`, and `presentation` modules. Adopt melos or package-level `analysis_options.yaml` to prevent cross-feature leakage.
- **TODO B — Supabase contract alignment**
  - Automate `supabase gen types dart` + `supabase gen types typescript` into CI and publish the outputs into shared packages consumed by Flutter (`core_contracts`) and Next (`supabase-contracts`). Enforce schema drift detection via `supabase db diff`.
- **TODO C — Multi-tenant RLS hardening**
  - Introduce automated SQL regression tests that execute `policies.sql` + representative seed data in CI. Ensure every multi-tenant table includes an explicit `tenant_id` (or equivalent) with matching RLS conditions. Document expected JWT claims in `docs/RLS-matrix.md`.

---

## Feature-First Refactor Proposal
1. **Define feature modules**: For each domain (Orders, Catalog, Admin, Finance, etc.), create a package that bundles:
   - `application/` (controllers/providers, Riverpod entry points).
   - `domain/` (entities, use cases, Freezed models).
   - `presentation/` (screens/widgets, localized strings).
   - `infrastructure/` (Supabase repositories, offline adapters).
   Each package should expose a public API via `lib/<feature>.dart` and register required providers through `ProviderContainer` extensions.

2. **Router segmentation**: Replace the monolithic `app_router.dart` with per-feature route registries (e.g., `orders_routes.dart`) that the root router composes. Role-based middleware should live with the feature to clarify ownership.

3. **Localization toolkit**: Generate strongly-typed localizations using `flutter gen-l10n`, store ARB files per feature, and expose translations through the feature packages. This enables tree-shaking of locale-specific assets.

4. **Offline integration contracts**: Each feature package defines its offline adapters, exposing `registerOfflineDependencies()` to ensure cache/queue registration occurs during boot. Add integration tests verifying offline-first behavior for critical flows.

5. **Supabase sync**: Pair each feature package with matching Supabase SQL documentation. For instance, the Orders package depends on `orders`, `order_items`, etc.; the package should include generated types and integration tests that execute the relevant Edge Functions against a local Supabase instance.

Implementing the above will improve ownership clarity, simplify onboarding, and reduce regressions by aligning Flutter features with Supabase responsibilities.
