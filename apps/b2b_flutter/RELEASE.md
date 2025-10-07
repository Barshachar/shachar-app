# Release Guide (Ashachar Marketplace)

## Flavors
- Dev: `--dart-define=ENV=dev` (local Supabase, ATS permissive for dev)
- Prod: `--dart-define=ENV=prod` (fill assets/config/app_config.prod.json with real values)

## Release Build Commands
- iOS: `flutter build ipa --release --dart-define=ENV=prod`
- Android: `flutter build apk --release --dart-define=ENV=prod`
- Web: `flutter build web --release --dart-define=ENV=prod`

## Continuous Integration
- Workflow: `.github/workflows/flutter.yml`
  - `Analyze & Unit Tests` runs on every push/PR touching `app/**`; it executes `flutter pub get`, `flutter analyze`, and `flutter test -r compact` from `app/`.
  - `Integration (macOS manual)` is `workflow_dispatch`-only. Trigger it via Actions → Flutter CI → Run workflow (choose branch) once macOS runners are available; the job runs from `app/` and executes `flutter test integration_test/order_flow_test.dart -r expanded --dart-define=ENV=dev --dart-define=INITIAL_ROUTE=/home`.
  - Download the generated logs/artifacts from each job summary before tagging a release.
  - Prod release reminder: tighten ATS and ship a `GoogleService-Info.plist` (see iOS section below).

## iOS (Simulator/Device)
- Simulator (debug):
  `flutter run -d <SIM_UDID> --debug --dart-define=ENV=dev`
- Release (App Store build – provisioning required):
  `flutter build ipa --release --dart-define=ENV=prod`
  - Ensure `ios/Runner/Info.plist` tightens ATS for prod (no `NSAllowsArbitraryLoads`, production domain exceptions only).
  - Production builds expect a `GoogleService-Info.plist` with the prod Firebase project; keep it in sync with your Xcode build configuration before archiving.

## Android
- Debug: `flutter run -d <android-device>`
- Release: `flutter build apk --release --dart-define=ENV=prod`

## Web
- Release build:
  `flutter build web --release --dart-define=ENV=prod`
- Output path: `build/web/`

## Supabase Notes
- For local dev: `supabase start` (CLI) → anon/service keys from `supabase status`
- RLS: production policies restrict read to authenticated buyers; demo anon-read removed
- Helper functions hardened in this drop:
  - `auth_role()` / `auth_company_id()` now fall back to JWT `app_metadata` and tenant bindings.
  - `order_item_customer_guard()` + `order_item_customer_company()` guard customer inserts without recursion.
  - `order_has_vendor()` powers vendor visibility without cycling through `order_items` policies.
- Functions live in `supabase/sql/schema.sql` (mirrored under `app/` and `staging/`). Run the QA script after pulling to ensure the local DB matches.

## Smoke Checklist
- Catalog → Cart → Submit → Split (Shipments created)
- Admin: Reports (Signed URL) + Price Import
- Vendor: Orders list (view)

## QA Automation
- `./scripts/qa-run.sh` (from repo root or `app/`) now:
  - Reconciles RLS helper functions/policies for `order_items` and `orders` before testing.
  - Builds & deploys the iOS simulator app with `--dart-define=ENV=dev`.
  - Runs analyzer, unit tests, and `integration_test/order_flow_test.dart` against the configured UDID.
- Output includes Supabase markers (`[ORDER_FLOW] …`) plus simulator log filtering for order submissions.

## QA Artifacts Checklist
- `/tmp/qa-run.log` from the latest `./scripts/qa-run.sh` run.
- `docs/screens/home_after_install.png`
- `docs/screens/catalog_search.png`
- `docs/screens/quick_order.png`
- (Optional) Store Supabase migration diff summaries alongside test results in the release folder.

## Tooling Hooks
- Optional pre-commit (place in `.pre-commit-config.yaml`):

```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-analyze
        name: flutter analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
      - id: flutter-test
        name: flutter test
        entry: flutter test
        language: system
        pass_filenames: false
```
