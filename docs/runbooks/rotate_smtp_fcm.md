# Runbook – Rotate SMTP / FCM Secrets

1. Generate new credentials (SMTP user/pass, FCM server key).
2. Update Supabase secrets:
   ```bash
   supabase secrets set SMTP_USER=... SMTP_PASS=... FCM_SERVER_KEY=...
   ```
3. Redeploy Edge functions `notify_status_change` and `report_generator` to pick up environment variables.
4. Update Flutter app `.env.json` (and anonymized values in `.env.sample`).
5. Clear caches in `analyticsService` by restarting apps (force logout) or sending remote config update.
6. Send smoke notifications (test order) and verify deliverability.
