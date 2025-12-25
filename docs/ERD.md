# Entity Relationship Overview

This section mirrors the Phase-1 ERD. Each table is scoped via tenancy enforced by RLS.

## Core Tables

- **companies** (`id`, `type`, `status`, `name`, `locale`, `currency`, `timezone`)
- **company_users** (`company_id`, `user_id`, `role`)
- **categories** → self-referencing hierarchy
- **products** → belongs to `vendor_company_id`
- **product_variants** → belongs to `products`
- **inventory** → per variant
- **price_lists** → vendor scoped, optional `target_id`
- **prices** → per list + variant + min_qty
- **orders** → customer scoped, includes cancellation metadata (`cancelled_at`, `cancelled_by`, `cancellation_reason`)
- **order_items** → order × vendor split
- **shipments** → order × vendor operational state
- **vendor_ratings** → order × vendor feedback (customer scoped)
- **returns** → return requests with status + audit trail for order lines
- **approval_requests** → approval workflow entries for orders (customer scoped)
- **attachments** / **notifications** / **audit_log** for operational telemetry

Materialized view `mv_effective_prices` pre-computes price cascade and feeds the secure view `secure_effective_prices` used by RPCs and the Flutter client.
View `vendor_rating_summary` aggregates vendor rating averages and counts for buyer-facing summaries.
