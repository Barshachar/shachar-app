# API Reference (Phase-1)

## Supabase REST Tables (selected)

- `products` – filters: `vendor_company_id`, `active`; includes nested `product_variants`
- `price_lists` – filters: `vendor_company_id`, `target_id`
- `orders` – filters: `customer_company_id`, `status`, `created_at`
- `order_items` – filters: `order_id`, `vendor_company_id`
- `shipments` – filters: `order_id`, `vendor_company_id`

## RPC

| RPC | Parameters | Description |
|-----|------------|-------------|
| `rpc_effective_price` | `p_customer uuid`, `p_variant uuid`, `p_qty numeric` | Returns the best matching price (customer > global) with currency & vendor reference |
| `rpc_submit_order` | `p_order_id uuid` | Validates draft order, resolves pricing, writes totals, transitions to `placed` |
| `rpc_upsert_prices` | `p_vendor uuid`, `p_rows jsonb` | Bulk upsert from CSV import, refreshes materialized view |
| `list_order_recipients` | `p_order_id uuid` | (Helper for Edge) – list of user IDs to notify |

## Edge Functions

| Function | Method | Payload | Purpose |
|----------|--------|---------|---------|
| `order_splitter` | `POST` | `{ "order_id": "uuid" }` | Creates/updates shipments per vendor |
| `notify_status_change` | `POST` | `{ "order_id": "uuid", "event": "text", "message"?: "text" }` | Fan-out notifications |
| `price_lists_import` | `POST` form-data | `vendor_id`, `file` | Parse CSV, call RPC, refresh MV |
| `report_generator` | `POST` | `{ "from_date"?, "to_date"?, "format" }` | Generate PDF/CSV, return signed URL |
| `low_stock_scanner` | `GET` | - | Cron job, create low stock notifications |

## Storage Buckets

- `kyc_docs` – private vendor onboarding documents (signed URL only)
- `attachments` – exported reports & order artifacts (signed URL delivery)
