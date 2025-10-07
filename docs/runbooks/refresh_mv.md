# Runbook – Refresh Effective Prices MV

1. Connect to the database: `supabase db connect`.
2. Execute: `select refresh_mv_effective_prices();`.
3. Verify: `select count(*) from mv_effective_prices;` compare to previous snapshot.
4. Notify pricing SMEs if rowcount significantly changes (>10%).
5. Edge fallback: call Edge function `price_lists_import` with empty payload to trigger refresh.
