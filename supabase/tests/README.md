# Supabase Test Harness

## RLS Regression Suite
- `rls_regressions.sql` validates tenant isolation by impersonating seeded users (`vendor_admin`, `buyer`) via JWT claims and ensuring cross-tenant reads/writes fail.
- Run after applying migrations, policies, and seed data:

```bash
psql "$SUPABASE_DB_URL" -f supabase/sql/schema.sql
psql "$SUPABASE_DB_URL" -f supabase/sql/policies.sql
psql "$SUPABASE_DB_URL" -f supabase/seed.sql
psql "$SUPABASE_DB_URL" -f supabase/tests/rls_regressions.sql
```

Any exception thrown indicates an RLS regression that must be addressed before deployment.
