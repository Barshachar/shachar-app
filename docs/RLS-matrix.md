# RLS Matrix (Phase-1)

| Table / View             | admin | vendor_admin / vendor_user | customer_admin / buyer | Notes |
|-------------------------|:-----:|:---------------------------:|:----------------------:|-------|
| companies               |  RW   |             R              |           R            | Vendors/customers see own company only |
| company_users           |  RW   |             R              |           R            | Scoped via `company_id = auth_company_id()` |
| categories / attributes |  RW   |             R              |           R            | Read-only for non-admin (global catalog) |
| products                |  RW   |             RW             |           R            | Vendors limited to their `vendor_company_id`; customers active only |
| product_variants        |  RW   |             RW             |           R            | Similar to products |
| inventory               |  RW   |             RW             |           R            | Customers read-only, vendor RW on own variants |
| price_lists / prices    |  RW   |             RW             |           R            | Customers see global + targeted lists |
| mv_effective_prices     |  R*   |             R*             |           R*           | Accessed via `secure_effective_prices` view |
| orders                  |  RW   |             R              |           RW           | Vendors view orders containing their items |
| order_items             |  RW   |             RW             |           R            | Customer scope via parent order |
| shipments               |  RW   |             RW             |           R            | |
| returns                 |  RW   |             -              |           -            | Disabled via feature flag |
| attachments             |  RW   |             W (own)        |           W (own)      | Creator-scoped writes |
| notifications           |  RW   |             W (own)        |           W (own)      | User scoped |
| audit_log               |  RW   |             -              |           -            | Admin-only audit access |

`R*` indicates the secure view applies row filters instead of table-level policies (materialized view).

- Admin-only RPC `admin_list_company_users` returns company directories using `auth_role()='admin'` and `auth_company_id()` to preserve tenant isolation.
