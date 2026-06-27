set search_path = public, auth;

-- Cashback admin tooling + earn notifications. Depends on patches 023–025.

-- Award now also notifies the buyer when cashback is earned. ------------------
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

  -- Notify the buyer who placed the order (best-effort).
  IF v_entry_id IS NOT NULL AND v_order.created_by IS NOT NULL THEN
    INSERT INTO notifications(user_id, title, body, data)
    VALUES (
      v_order.created_by,
      'צברת זיכוי',
      'קיבלת ' || to_char(v_amount, 'FM999990.00')
        || ' ש"ח זיכוי על הזמנה ' || v_order.order_number,
      jsonb_build_object(
        'order_id', p_order_id,
        'type', 'cashback_earned',
        'amount', v_amount
      )
    );
  END IF;

  RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

-- Admin: manual adjustment (positive or negative) -----------------------------
CREATE OR REPLACE FUNCTION rpc_adjust_cashback(
  p_company uuid,
  p_amount numeric,
  p_note text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
  v_entry_id uuid;
BEGIN
  IF auth_role() <> 'admin' THEN
    RAISE EXCEPTION 'Only admins may adjust cashback' USING errcode = '42501';
  END IF;
  IF p_amount IS NULL OR p_amount = 0 THEN
    RAISE EXCEPTION 'Adjustment amount must be non-zero';
  END IF;

  INSERT INTO cashback_ledger(customer_company_id, entry_type, amount, currency, note)
  VALUES (p_company, 'adjust', round(p_amount, 2), 'ILS',
          COALESCE(p_note, 'Manual adjustment'))
  RETURNING id INTO v_entry_id;

  RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION rpc_adjust_cashback(uuid, numeric, text) TO authenticated, service_role;

-- Admin: cashback overview (balance per company) ------------------------------
CREATE OR REPLACE FUNCTION rpc_cashback_overview()
RETURNS TABLE(company_id uuid, company_name text, balance numeric) AS $$
BEGIN
  IF auth_role() <> 'admin' THEN
    RAISE EXCEPTION 'Only admins may view the cashback overview' USING errcode = '42501';
  END IF;

  RETURN QUERY
    SELECT c.id, c.name, COALESCE(SUM(l.amount), 0)::numeric(14,2)
      FROM companies c
      JOIN cashback_ledger l ON l.customer_company_id = c.id
     GROUP BY c.id, c.name
     HAVING COALESCE(SUM(l.amount), 0) <> 0
     ORDER BY 3 DESC;
END;
$$ LANGUAGE plpgsql
   STABLE
   SECURITY DEFINER
   SET search_path = public, auth;

GRANT EXECUTE ON FUNCTION rpc_cashback_overview() TO authenticated, service_role;
