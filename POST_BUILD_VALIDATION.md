# Post-Build Validation Checklist

- [ ] Supabase local stack running and anon key configured in `.env.json`.
- [ ] Login as `admin@demo.local / Demo123!`; Vendor queue shows pending vendors and approve action executes (mock).
- [ ] Login as `buyer1@demo.local` and verify catalog prices load, add to cart, submit draft (RPC) without approvals.
- [ ] Vendor workspace lists split orders per vendor (via `order_splitter`).
- [ ] Admin report export triggers `report_generator` and returns signed URL.
- [ ] RLS negative tests (inside `policies.sql`) pass during `supabase db reset`.
- [ ] `flutter test` and Deno tests green.
- [ ] GitHub Actions CI green with uploaded artifacts (web build + APK built locally).
