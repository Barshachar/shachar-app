# Operations Playbook

## הרצה מקומית

1. **Supabase** – הפעל `supabase start` פעם אחת. לשחזור סכימה והזרעת נתונים להרצה מקומית:
   ```bash
   cd supabase
   supabase db reset --no-seed --yes
   psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f sql/schema_applied.sql
   psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f sql/policies_apply.sql
   psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -f seed.sql
   ```
2. **Flutter** – התקן תלויות והריץ:
   ```bash
   cd apps/b2b_flutter
   flutter pub get
   flutter run
   ```
3. **PWA** – עובר ל־local-only:
   ```bash
   cd apps/web_pwa
   pnpm install
   pnpm dev
   ```

## בדיקות

- PWA: `pnpm -C apps/web_pwa typecheck && pnpm -C apps/web_pwa test`
- Flutter: `cd apps/b2b_flutter && flutter test --reporter=expanded`
- SQL/RLS: `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/rls_regressions.sql`  
  וכן `orders_submit_test.sql` ו־`pricing_rls_test.sql`
- Edge (Deno): `deno test supabase/functions/price_lists_import/index.test.ts`
- Contracts: `pnpm -C packages/contracts test && pnpm -C packages/contracts build`

### Supabase TS Typegen Guard (Local)
1. ודאו Node 20 פעיל:
   ```bash
   nvm use 20
   corepack enable
   ```
2. הגדירו `DATABASE_URL` ל-DB עם סכימה מעודכנת:
   ```bash
   export DATABASE_URL=postgres://postgres:postgres@127.0.0.1:54322/postgres
   ```
3. הריצו:
   ```bash
   bash .ci/guard-typegen-ts.sh
   ```

## לפני PR

1. הרץ את כל הבדיקות לעיל + `pnpm -C apps/web_pwa typecheck`.
2. ודא ש־`rg "createServiceRoleClient(" apps/web_pwa | rg -v "app/api/admin/"` מחזיר תוצאה ריקה.
3. מלא את תבנית ה־PR החדשה (תיאור, אינוואריאנטים, בדיקות שנרצו).
4. אם נגעת ב־Supabase (schema/policies) – צרף קובץ SQL Test מתאים או עדכון קיים.
