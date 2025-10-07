# Runbook – Deploy Supabase + Flutter

1. **Prerequisites**: Supabase project linked, Docker running, environment variables stored in CI/CD secrets (`SUPABASE_DB_PASSWORD`, `SUPABASE_SERVICE_ROLE_KEY`, `SENTRY_DSN`).
2. **Database**:
   - `supabase db push` to apply schema/policies.
   - `supabase db reset --seed-file supabase/seeds/seed.sql` for staging refresh.
   - Monitor for errors in RLS negative tests section.
3. **Edge functions**:
   - `supabase functions deploy order_splitter notify_status_change price_lists_import report_generator low_stock_scanner`.
   - Verify logs via `supabase functions logs <name>`.
4. **Flutter Web**:
   - `flutter build web --release` (see `supabase/scripts/build-web.sh`).
   - Upload `build/web` to hosting (Supabase storage or static host).
5. **Flutter Mobile**:
   - `flutter build apk --release` and distribute via internal track.
6. **Smoke Validation**: Run checklist from `POST_BUILD_VALIDATION.md` and observe analytics dashboards.
