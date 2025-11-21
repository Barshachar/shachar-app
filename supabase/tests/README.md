# Supabase Test Harness

## RLS Regression Suite
- `rls_regressions.sql` validates tenant isolation by impersonating seeded users (`vendor_admin`, `buyer`) via JWT claims and ensuring cross-tenant reads/writes fail.
- Run after applying migrations, policies, and seed data using the dev database URL (`postgres://postgres:postgres@127.0.0.1:54322/postgres`) with an admin role (`PGOPTIONS='-c role=supabase_admin'`):

```bash
PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -f supabase/sql/schema.sql
PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -f supabase/sql/policies.sql
PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -f supabase/seed.sql
PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -f supabase/tests/rls_regressions.sql
```

Any exception thrown indicates an RLS regression that must be addressed before deployment.

## RLS Assertions on clean DB
- `setup_test_db.sql` rebuilds the `public` schema, applies schema/policies/seeds, and then runs `rls_assertions.sql`.
- Use this script locally when policies fail to apply due to existing data, and wire it in CI before running `rls_regressions.sql`:

```bash
PGOPTIONS='-c role=supabase_admin' psql "$DATABASE_URL" -f supabase/tests/setup_test_db.sql
```
