# Security Review — Supabase RLS (א.שחר Marketplace)

## Overview
- **Scope**: `supabase/sql/policies.sql`, helper functions (`auth_*`), seed data, and new regression suite (`supabase/tests/rls_regressions.sql`).
- **Objective**: Validate and tighten multi-tenant isolation keyed by `company_id` + `auth_role()`, highlight risks, and prescribe remediation steps.

## Current Posture
- RLS is enabled for all marketplace tables (orders, products, inventory, price lists, saved lists, support tickets, storage objects, etc.).
- Policies rely on helpers:
  - `auth_role()` / `auth_company_id()` extracted from JWT claims.
  - Guard functions (`order_has_vendor`, `order_item_customer_guard`) enforce relational checks.
- Negative sanity checks already exist within `policies.sql` (DO blocks) but were not previously automated.

## Enhancements Applied
1. **Regression Automation**  
   - Added `supabase/tests/rls_regressions.sql` with scenario-based assertions:
     - Vendors cannot read or mutate orders/products tied to other tenants.
     - Customers cannot read or insert orders for foreign companies.
     - Vendors cannot update price lists belonging to other vendors.
   - Provides a deterministic harness for CI / local verification (see `supabase/tests/README.md`).

2. **Documentation**  
   - Created `supabase/tests/README.md` with execution steps to integrate the regression suite into CI.

## Residual Risks
- **JWT Claim Integrity**: RLS depends on `request.jwt.claims` providing `role` + `company_id`. Missing or tampered claims could bypass policies. Need Gateway validation and explicit checks for `coalesce(auth_role(), '') <> ''`.
- **Table Coverage Drift**: New tables must be added to policies + regression suite to prevent gaps.
- **Function Privileges**: Edge Functions using the service role can bypass RLS; ensure functions impersonate end-users (use `auth-` tokens) when feasible.

## Recommended Actions
1. **Automate in CI** (High)  
   - Add a Supabase workflow step to run `psql -f supabase/tests/rls_regressions.sql` after migrations/seeds. Fail builds on any exception.
2. **Claims Hardening** (High)  
   - Extend helper functions to raise an error when `auth_role()` or `auth_company_id()` resolve to `null`, preventing anonymous service access paths.
3. **Edge Function Audits** (Medium)  
   - Ensure Edge Functions avoid using the service-role key directly for tenant-specific operations. Prefer user-session keys or enforce explicit tenant filters server-side.
4. **Future Tables** (Medium)  
   - Adopt a checklist: when creating a new table, add `alter table ... enable row level security`, at least one policy, and a regression assertion.

## Conclusion
Supabase RLS policies enforce tenant separation for existing surfaces. The new regression suite formalizes these guarantees, but continuous enforcement (CI integration) and stricter JWT validation are required to maintain isolation as the schema evolves.
