set search_path = public, auth;

-- Phase 1 of the cashback program: configurable earn rate + redemption.
-- Depends on patch 023_cashback_ledger.sql.

-- Per-company (or global default) cashback configuration -----------------------
CREATE TABLE IF NOT EXISTS public.cashback_config (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id uuid REFERENCES public.companies(id) ON DELETE CASCADE, -- NULL = global default
  rate_pct numeric(5,2) NOT NULL DEFAULT 1.00,   -- percent of order total
  max_balance numeric(14,2),                      -- NULL = unlimited
  expiry_days integer,                            -- NULL = never expires (enforcement is a follow-up)
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT cashback_config_rate_nonneg CHECK (rate_pct >= 0),
  CONSTRAINT cashback_config_expiry_pos CHECK (expiry_days IS NULL OR expiry_days > 0)
);

-- One row per company, and a single global-default row.
CREATE UNIQUE INDEX IF NOT EXISTS cashback_config_company_uidx
  ON public.cashback_config(company_id) WHERE company_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS cashback_config_global_uidx
  ON public.cashback_config((company_id IS NULL)) WHERE company_id IS NULL;

-- Seed the global default (1%) if absent.
INSERT INTO public.cashback_config (company_id, rate_pct)
SELECT NULL, 1.00
WHERE NOT EXISTS (SELECT 1 FROM public.cashback_config WHERE company_id IS NULL);

ALTER TABLE public.cashback_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS cashback_config_admin_all ON public.cashback_config;
CREATE POLICY cashback_config_admin_all ON public.cashback_config
  FOR ALL
  USING (auth_role() = 'admin')
  WITH CHECK (auth_role() = 'admin');

-- Customers may read their own company's config and the global default.
DROP POLICY IF EXISTS cashback_config_customer_read ON public.cashback_config;
CREATE POLICY cashback_config_customer_read ON public.cashback_config
  FOR SELECT TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND (company_id IS NULL OR company_id = auth_company_id())
  );

-- Effective cashback fraction for a company (company override > global > 1%).
CREATE OR REPLACE FUNCTION cashback_rate_for(p_company uuid)
RETURNS numeric
LANGUAGE sql
STABLE
SET search_path = public, auth
AS $$
  SELECT COALESCE(
    (SELECT rate_pct / 100 FROM cashback_config
      WHERE company_id = p_company AND active LIMIT 1),
    (SELECT rate_pct / 100 FROM cashback_config
      WHERE company_id IS NULL AND active LIMIT 1),
    0.01
  );
$$;

GRANT EXECUTE ON FUNCTION cashback_rate_for(uuid) TO authenticated, service_role;

-- Award now reads the rate from config and respects max_balance. -------------
-- CREATE OR REPLACE preserves the service_role-only ACL from patch 023.
CREATE OR REPLACE FUNCTION rpc_award_order_cashback(p_order_id uuid)
RETURNS uuid AS $$
DECLARE
  v_rate numeric;
  v_max numeric(14,2);
  v_balance numeric(14,2);
  v_order orders%rowtype;
  v_total numeric(14,2);
  v_amount numeric(14,2);
  v_entry_id uuid;
BEGIN
  SELECT * INTO v_order FROM orders WHERE id = p_order_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order % not found', p_order_id;
  END IF;

  IF v_order.status <> 'delivered' THEN
    RAISE EXCEPTION 'Cashback can only be awarded for delivered orders (order % is %)',
      p_order_id, v_order.status;
  END IF;

  IF EXISTS (
    SELECT 1 FROM cashback_ledger
     WHERE order_id = p_order_id AND entry_type = 'earn'
  ) THEN
    RETURN NULL;
  END IF;

  v_total := COALESCE(v_order.total, 0);
  IF v_total <= 0 THEN
    SELECT COALESCE(SUM(line_total), 0) INTO v_total
      FROM order_items WHERE order_id = p_order_id;
  END IF;

  v_rate := cashback_rate_for(v_order.customer_company_id);
  v_amount := round(v_total * v_rate, 2);

  -- Cap so the resulting balance never exceeds the configured maximum.
  SELECT max_balance INTO v_max FROM cashback_config
    WHERE company_id = v_order.customer_company_id AND active
    LIMIT 1;
  IF v_max IS NULL THEN
    SELECT max_balance INTO v_max FROM cashback_config
      WHERE company_id IS NULL AND active LIMIT 1;
  END IF;
  IF v_max IS NOT NULL THEN
    SELECT COALESCE(SUM(amount), 0) INTO v_balance
      FROM cashback_ledger WHERE customer_company_id = v_order.customer_company_id;
    IF v_balance + v_amount > v_max THEN
      v_amount := v_max - v_balance;
    END IF;
  END IF;

  IF v_amount <= 0 THEN
    RETURN NULL;
  END IF;

  INSERT INTO cashback_ledger(customer_company_id, order_id, entry_type, amount, currency, note)
  VALUES (
    v_order.customer_company_id,
    p_order_id,
    'earn',
    v_amount,
    COALESCE(v_order.currency, 'ILS'),
    'Cashback for order ' || v_order.order_number
  )
  ON CONFLICT (order_id) WHERE entry_type = 'earn' AND order_id IS NOT NULL
  DO NOTHING
  RETURNING id INTO v_entry_id;

  RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

-- Redemption ------------------------------------------------------------------
-- A customer redeems their OWN cashback (tenant taken from auth_company_id(), so
-- it cannot be spoofed). Balance is checked and the per-company write is
-- serialized with an advisory lock to prevent concurrent double-spend.
CREATE OR REPLACE FUNCTION rpc_redeem_cashback(p_amount numeric, p_order_id uuid DEFAULT NULL)
RETURNS uuid AS $$
DECLARE
  v_company uuid := auth_company_id();
  v_role user_role := auth_role();
  v_balance numeric(14,2);
  v_entry_id uuid;
BEGIN
  IF v_company IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING errcode = '28000';
  END IF;
  IF v_role NOT IN ('customer_admin','buyer','admin') THEN
    RAISE EXCEPTION 'Role % cannot redeem cashback', v_role USING errcode = '42501';
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'Redeem amount must be positive';
  END IF;

  -- Serialize redemptions per company so balance checks can't race.
  PERFORM pg_advisory_xact_lock(hashtext(v_company::text));

  SELECT COALESCE(SUM(amount), 0) INTO v_balance
    FROM cashback_ledger WHERE customer_company_id = v_company;

  IF p_amount > v_balance THEN
    RAISE EXCEPTION 'Insufficient cashback balance (have %, requested %)',
      v_balance, p_amount USING errcode = '22023';
  END IF;

  INSERT INTO cashback_ledger(customer_company_id, order_id, entry_type, amount, currency, note)
  VALUES (v_company, p_order_id, 'redeem', -round(p_amount, 2), 'ILS', 'Cashback redeemed')
  RETURNING id INTO v_entry_id;

  RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION rpc_redeem_cashback(numeric, uuid) TO authenticated, service_role;
