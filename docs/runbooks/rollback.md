# Runbook – Rollback Procedure

1. **Database**: restore from latest PITR snapshot (`supabase db restore <timestamp>`). Confirm with `select count(*) from orders;`.
2. **Edge Functions**: redeploy previous tag `supabase functions deploy <name> --project-ref <ref> --import-map from git tag`.
3. **Flutter Apps**: redeploy previous CI artifact (APK / web bundle). Invalidate CDN caches.
4. **Post-rollback**: run `supabase db diff` to ensure schema matches expectations, rerun `POST_BUILD_VALIDATION.md` assertions, notify stakeholders in #ops.
