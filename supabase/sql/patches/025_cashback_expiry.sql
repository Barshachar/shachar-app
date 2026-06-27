set search_path = public, auth;

-- Cashback expiry sweep. Depends on patches 023 + 024.
--
-- Expires the unconsumed portion of cashback earned before now() - expiry_days,
-- using FIFO lot accounting: debits (redeem/expire/negative adjust) are applied
-- against the OLDEST credits first, and whatever remains on aged credits is
-- expired. Because each run writes a negative 'expire' row, that amount counts
-- as consumed on the next run, so the sweep is idempotent and never
-- double-expires.
--
-- Intended to be invoked on a schedule (e.g. pg_cron or an Edge Function cron).

CREATE OR REPLACE FUNCTION rpc_expire_cashback()
RETURNS integer AS $$
DECLARE
  v_rows integer := 0;
  v_company record;
  v_cutoff timestamptz;
  v_consumed numeric(14,2);
  v_expire numeric(14,2);
BEGIN
  FOR v_company IN
    SELECT c.id AS company_id,
           COALESCE(cfg.expiry_days, gcfg.expiry_days) AS expiry_days
      FROM companies c
      LEFT JOIN cashback_config cfg
        ON cfg.company_id = c.id AND cfg.active
      LEFT JOIN cashback_config gcfg
        ON gcfg.company_id IS NULL AND gcfg.active
     WHERE COALESCE(cfg.expiry_days, gcfg.expiry_days) IS NOT NULL
  LOOP
    v_cutoff := now() - make_interval(days => v_company.expiry_days);

    -- Total debits already applied for this company (positive number).
    SELECT COALESCE(-SUM(amount), 0) INTO v_consumed
      FROM cashback_ledger
     WHERE customer_company_id = v_company.company_id
       AND amount < 0;

    -- FIFO: for each credit lot (oldest first), the unconsumed amount is
    -- least(lot, greatest(0, cumulative_credits_incl - consumed)). Sum the
    -- unconsumed amount of lots older than the cutoff.
    SELECT COALESCE(SUM(
             LEAST(p.amount, GREATEST(0, p.cum_incl - v_consumed))
           ), 0) INTO v_expire
      FROM (
        SELECT id, amount, created_at,
               SUM(amount) OVER (ORDER BY created_at, id) AS cum_incl
          FROM cashback_ledger
         WHERE customer_company_id = v_company.company_id
           AND amount > 0
      ) p
     WHERE p.created_at < v_cutoff;

    IF v_expire > 0 THEN
      INSERT INTO cashback_ledger(customer_company_id, entry_type, amount, currency, note)
      VALUES (
        v_company.company_id,
        'expire',
        -round(v_expire, 2),
        'ILS',
        'Cashback expired after ' || v_company.expiry_days || ' days'
      );
      v_rows := v_rows + 1;
    END IF;
  END LOOP;

  RETURN v_rows;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

-- Sweep is a privileged maintenance job: service_role only.
REVOKE EXECUTE ON FUNCTION rpc_expire_cashback() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION rpc_expire_cashback() TO service_role;
