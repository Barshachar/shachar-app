# Status Characterization

## Route Map
| Path | Route Name | Widget | Notes |
| --- | --- | --- | --- |
| `/loading` | `loading` | `LoadingScaffold` | Transitional screen while auth/session hydrates. |
| `/` | `root` | Redirect | Redirects to role-specific start (admin/vendor/customer) once profile resolved. |
| `/catalog` | `catalog` | `CatalogPage` | Shell route hosting catalog sub-routes. Requires authenticated session; auto demo login kicks in dev. |
| `/catalog/product/:id` | `product` | `ProductPage` | Child of catalog; shows product detail. |
| `/catalog/search` | `catalog-search` | `CatalogSearchPage` | Full-screen search results. |
| `/catalog/quick-order` | `quick-order` | `QuickOrderPage` | Bulk ordering workspace with filters and import. |
| `/home` | `home` | Redirect | Added guard to redirect to `/customer` so INITIAL_ROUTE=`/home` works in dev. |
| `/customer` | `customer-home` | `CustomerHomePage` | Customer landing tiles (Catalog, Cart, Orders, Quick Order). |
| `/customer/cart` | `cart` | `CartPage` | Draft cart review and submit. |
| `/customer/orders` | `customer-orders` | `OrdersPage` | Lists customer orders; nests detail route. |
| `/customer/orders/:id` | `order-detail` | `OrderDetailPage` | Shows totals, shipments, reorder actions. |
| `/vendor` | `vendor-home` | `VendorOrdersPage` | Vendor shipment management shell (RTL aware). |
| `/vendor/products` | `vendor-products` | `VendorProductsPage` | Vendor catalog maintenance list. |
| `/admin` | `admin-home` | `AdminDashboardPage` | Web-first admin dashboard shell. |
| `/admin/vendor-queue` | `vendor-queue` | `VendorQueuePage` | Vendor onboarding queue. |
| `/admin/customers` | `admin-customers` | `AdminCustomersPage` | Customer directory. |
| `/admin/catalog` | `admin-catalog` | `AdminCatalogPage` | Catalog management. |
| `/admin/price-lists` | `price-lists` | `AdminPriceListsPage` | CSV import/export + price editing. |
| `/admin/orders` | `admin-orders` | `AdminOrdersPage` | Order moderation and split flow. |
| `/admin/reports` | `admin-reports` | `AdminReportsPage` | Generates signed CSV reports. |
| `/admin/audit-log` | `admin-audit-log` | `AdminAuditLogPage` | Audit trail viewer. |
| `/admin/settings` | `admin-settings` | `AdminSettingsPage` | Global configuration toggles. |

## Screen & Flow Status
### Customer Home (`/customer`)
- Tiles navigate via `context.go` to Catalog, Cart, Orders, Quick Order; confirmed by `[NAV]` logs during QA run.
- Debug auth entry point now shows SnackBars instead of crashing on failure.

### Catalog
- Auto demo sign-in executes during bootstrap; QA log shows `[INFO] Demo sign-in result: true` before catalog render.
- `catalog_controller` refresh triggers once post-frame; product list and Test Order FAB exercised by integration test (`order_flow_test`) with successful draft creation and submission.
- Search route reachable (AppBar action). No regressions observed; analyzer/tests green.

### Catalog Search
- Screen capture produced (`docs/screens/catalog_search.png`) via flutter drive; indicates layout renders with seeded data.
- Search/filter logic relies on Supabase queries; no dedicated automated assertions beyond rendering.

### Quick Order
- Screen capture (`docs/screens/quick_order.png`) confirms UI boots with categories pane, filters, bulk input.
- Page supports debounced search, pagination, CSV paste, undo batches (`_UndoBatch`), but lacks e2e coverage; manual validation pending.

### Cart & Checkout Draft
- `cart_controller_test.dart` covers draft creation, quantity adjustments, submit + navigation.
- `CartPage` guards async calls with SnackBars and retries; linear progress and error states localized (Hebrew strings).
- No integration test hitting `/customer/cart`; manual smoke still advised.

### Orders List & Detail
- Widget tests cover empty state, detail sections (totals, shipments) and reorder scenarios.
- Integration order flow navigates automatically to `/customer/orders/<id>` after submission and verifies shipments exist server-side.

### Vendor Console
- `vendor_orders_page` wiring present, but associated integration test is `skip: true`; no automated confirmation of live data.
- `vendor_products` lacks targeted tests. Treat vendor flows as unverified.

### Admin Console
- Dashboard and navigation render (tested indirectly via routing), but critical flows (`Split Order`, `Reports CSV`, `Price import`) are skipped integration tests.
- Requires manual QA; CSV import uses fake file picker in tests but flagged skip.

### Auth States
- Dev launch automatically signs in buyer demo account; `[AUTH_FLOW]` instrumentation ready to surface exceptions.
- Manual login via debug sheet now wraps `signInWithPassword` in try/catch, guards `sheetContext.mounted`, and shows `SnackBar('Login failed: …')`. Navigation uses `goNamed` with explicit names eliminating literal paths.
- ErrorWidget builder prevents red screens, displaying friendly Hebrew message while logging stack traces.

## Known Gaps & TODOs
- **P0** – Vendor flows lack coverage: re-enable and stabilize `Vendor: Orders page lists vendor shipments` integration test (currently skipped) and add assertions for shipment actions.
- **P0** – Admin power-user workflows (`Split Order`, `Reports CSV`, `Price import`) remain `skip: true`; need backend fixtures or mocks plus RLS regression before marking ready.
- **P1** – `flutter drive (ui capture)` step reports FAIL in summary despite passing (likely script bookkeeping bug); investigate `QA_STATUS` aggregation and ensure final status matches step result.
- **P1** – Quick Order bulk CSV/undo flow lacks automated validation; add widget/integration tests covering `_BulkReviewRow` states and `_UndoBatch` execution.
- **P2** – Route `/home` currently redirects to `/customer`; consider dedicated customer landing alias to avoid double navigation in analytics if `/home` becomes public entry point.

## QA Artifacts
- Screenshots: `docs/screens/home_after_install.png`, `docs/screens/catalog_search.png`, `docs/screens/quick_order.png`
- Consolidated log: `/tmp/qa-run.log`
