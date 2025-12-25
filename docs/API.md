# API Reference (Phase-1)

## Supabase REST Tables (selected)

- `products` – filters: `vendor_company_id`, `active`; includes nested `product_variants`
- `price_lists` – filters: `vendor_company_id`, `target_id`
- `orders` – filters: `customer_company_id`, `status`, `created_at`
- `order_items` – filters: `order_id`, `vendor_company_id`
- `shipments` – filters: `order_id`, `vendor_company_id`
- `vendor_ratings` – filters: `vendor_company_id`, `customer_company_id`, `order_id`
- `vendor_rating_summary` – aggregated vendor rating counts/averages

## RPC

| RPC | Parameters | Description |
|-----|------------|-------------|
| `rpc_effective_price` | `p_customer uuid`, `p_variant uuid`, `p_qty numeric` | Returns the best matching price (customer > global) with currency & vendor reference |
| `rpc_submit_order` | `p_order_id uuid` | Validates draft order, resolves pricing, writes totals, transitions to `placed` |
| `rpc_upsert_prices` | `p_vendor uuid`, `p_rows jsonb` | Bulk upsert from CSV import, refreshes materialized view |
| `rpc_approvals_inbox` | - | Lists pending approval requests assigned to the current approver |
| `rpc_evaluate_approvals` | `p_order_id uuid` | Ensures an approval request exists for an order (returns request metadata) |
| `rpc_approve_step` | `p_step_id uuid`, `p_order_id uuid`, `p_decision text`, `p_note text` | Records approve/reject decision for an approval request |
| `list_order_recipients` | `p_order_id uuid` | (Helper for Edge) – list of user IDs to notify |

## Edge Functions

| Function | Method | Payload | Purpose |
|----------|--------|---------|---------|
| `order_splitter` | `POST` | `{ "order_id": "uuid" }` | Creates/updates shipments per vendor |
| `notify_status_change` | `POST` | `{ "order_id": "uuid", "event": "text", "message"?: "text" }` | Fan-out notifications |
| `price_lists_import` | `POST` form-data | `vendor_id`, `file` | Parse CSV, call RPC, refresh MV |
| `report_generator` | `POST` | `{ "from_date"?, "to_date"?, "format" }` | Generate PDF/CSV, return signed URL |
| `low_stock_scanner` | `GET` | - | Cron job, create low stock notifications |
| `vendor_rating_submit` | `POST` | `{ "order_id": "uuid", "vendor_company_id": "uuid", "rating": 1-5, "comment"?: "text" }` | Submit a vendor rating (offline queue compatible) |
| `return_request_submit` | `POST` | `{ "order_id": "uuid", "order_item_id": "uuid", "qty": "number", "reason"?: "text" }` | Submit a return request (offline queue compatible) |
| `order_cancel_submit` | `POST` | `{ "order_id": "uuid", "reason"?: "text" }` | Cancel an order before shipment (offline queue compatible) |
| `support_ai_assistant` | `POST` | `{ "message": "text", "history"?: [{ "role": "user|assistant", "text": "text" }] }` | AI support assistant with quick suggestions |

## Storage Buckets

- `kyc_docs` – private vendor onboarding documents (signed URL only)
- `attachments` – exported reports & order artifacts (signed URL delivery)
