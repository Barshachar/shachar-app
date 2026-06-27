set search_path = public, auth;

-- Customer cashback ledger.
--
-- Design notes:
--  * Append-only, value-per-row ledger. The balance is always sum(amount), so
--    we never mutate rows in place. Positive amount = credit (earn/adjust),
--    negative = debit (redeem/expire).
--  * Denominated in ILS only. Bitcoin is a display-only concept (computed in
--    the app from a live rate); no BTC amount is ever stored here.
--  * Writes are restricted to admin / service-role. Customers can read their
--    own rows but cannot credit themselves (see RLS below).

-- Movement type enum.
DO $$
BEGIN
  CREATE TYPE cashback_entry_type AS ENUM ('earn', 'redeem', 'expire', 'adjust');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

CREATE TABLE IF NOT EXISTS public.cashback_ledger (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  order_id uuid REFERENCES public.orders(id) ON DELETE SET NULL,
  entry_type cashback_entry_type NOT NULL,
  amount numeric(14,2) NOT NULL,
  currency text NOT NULL DEFAULT 'ILS',
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS cashback_ledger_company_idx
  ON public.cashback_ledger(customer_company_id, created_at DESC);

-- Guard: at most one 'earn' row per order, so re-running the award is a no-op.
CREATE UNIQUE INDEX IF NOT EXISTS cashback_ledger_earn_once_idx
  ON public.cashback_ledger(order_id)
  WHERE entry_type = 'earn' AND order_id IS NOT NULL;

-- Aggregate balance per customer. security_invoker keeps the underlying table's
-- RLS in force when the view is queried.
DROP VIEW IF EXISTS public.cashback_balances;
CREATE VIEW public.cashback_balances
  WITH (security_invoker = true) AS
  SELECT customer_company_id,
         COALESCE(SUM(amount), 0)::numeric(14,2) AS balance,
         max(currency) AS currency
    FROM public.cashback_ledger
   GROUP BY customer_company_id;

GRANT SELECT ON public.cashback_balances TO authenticated;

-- Row Level Security ----------------------------------------------------------
ALTER TABLE public.cashback_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS cashback_admin_all ON public.cashback_ledger;
CREATE POLICY cashback_admin_all ON public.cashback_ledger
  FOR ALL
  USING (auth_role() = 'admin')
  WITH CHECK (auth_role() = 'admin');

-- Customers may READ their own cashback only. No insert/update/delete policy is
-- defined for them, so RLS denies all writes from customer roles; credits are
-- written exclusively by the SECURITY DEFINER RPC / service role.
DROP POLICY IF EXISTS cashback_customer_read ON public.cashback_ledger;
CREATE POLICY cashback_customer_read ON public.cashback_ledger
  FOR SELECT TO authenticated
  USING (
    auth_role() IN ('customer_admin','buyer')
    AND customer_company_id = auth_company_id()
  );

-- Award RPC -------------------------------------------------------------------
-- Credits cashback for a single order. Idempotent: a second call for the same
-- order does nothing (enforced by cashback_ledger_earn_once_idx).
-- Cashback rate is a fixed 1% of the order total for now; promote to config
-- when business rules require per-company / per-tier rates.
DROP FUNCTION IF EXISTS rpc_award_order_cashback(uuid);
CREATE OR REPLACE FUNCTION rpc_award_order_cashback(p_order_id uuid)
RETURNS uuid AS $$
DECLARE
  v_rate constant numeric := 0.01;
  v_order orders%rowtype;
  v_total numeric(14,2);
  v_amount numeric(14,2);
  v_entry_id uuid;
BEGIN
  SELECT * INTO v_order FROM orders WHERE id = p_order_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Order % not found', p_order_id;
  END IF;

  -- Defense-in-depth: only fulfilled orders earn cashback, even if this RPC is
  -- somehow invoked outside the delivery trigger.
  IF v_order.status <> 'delivered' THEN
    RAISE EXCEPTION 'Cashback can only be awarded for delivered orders (order % is %)',
      p_order_id, v_order.status;
  END IF;

  -- Already awarded? no-op.
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

  v_amount := round(v_total * v_rate, 2);
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

-- Execution is restricted to service_role only. Customers must never be able to
-- credit themselves by calling this RPC directly; the auto-award trigger below
-- runs as SECURITY DEFINER (owned by the migration role) and can still call it.
REVOKE EXECUTE ON FUNCTION rpc_award_order_cashback(uuid) FROM PUBLIC, authenticated;
GRANT EXECUTE ON FUNCTION rpc_award_order_cashback(uuid) TO service_role;

-- Auto-award trigger ----------------------------------------------------------
-- Awards cashback when an order reaches the fulfilled 'delivered' state.
-- NOTE: this schema's order_status enum has no 'paid' value (payment state is
-- tracked in the web storefront's separate order representation), so 'delivered'
-- is the canonical "order completed, customer keeps the goods" trigger here.
CREATE OR REPLACE FUNCTION trg_award_cashback_on_delivery()
RETURNS trigger AS $$
BEGIN
  IF NEW.status = 'delivered'
     AND NEW.status IS DISTINCT FROM OLD.status THEN
    -- Only trusted delivery transitions award cashback. The orders_customer_rw
    -- policy lets customers update their own orders, so a customer self-marking
    -- an order 'delivered' must NOT credit cashback. auth_role() is NULL for the
    -- service role / server-side jobs, and a real role for admin/vendor actors.
    IF auth_role() IS NULL
       OR auth_role() IN ('admin', 'vendor_admin', 'vendor_user') THEN
      PERFORM rpc_award_order_cashback(NEW.id);
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

DROP TRIGGER IF EXISTS award_cashback_on_delivery ON public.orders;
CREATE TRIGGER award_cashback_on_delivery
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION trg_award_cashback_on_delivery();
