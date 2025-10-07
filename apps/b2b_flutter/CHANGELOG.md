# Changelog

## 2025-09-23
- Hardened Supabase auth helpers (`auth_role()`, `auth_company_id()`) to honor JWT `app_metadata` and tenant bindings.
- Added security-definer guards for order inserts (`order_item_customer_guard`) and vendor visibility (`order_has_vendor`) to eliminate RLS recursion.
- Ensured `rpc_create_draft` is idempotent, session-aware, and audited; tightened `rpc_submit_order` pricing loop.
- Updated QA orchestration to reconcile policies/functions before building, launch iOS simulator (`ENV=dev`), and execute analyzer/unit/integration suites.
- Added end-to-end integration test (`integration_test/order_flow_test.dart`) that drives the “Test Order” debug flow and waits for Order Detail navigation.
- Surfaced debug feature toggles via `debugFeaturesEnabledProvider`, making the “Test Order” FAB available in seeded dev builds.
