-- RLS assertions run on a clean test database.
-- Requires schema.sql, seed.sql, and policies.sql to be applied first.
\set ON_ERROR_STOP on

-- Vendor should not read other customers' orders
set role authenticated;
set session "request.jwt.claims" = '{"role": "vendor_admin", "company_id": "20000000-0000-0000-0000-000000000000"}';
DO $$
DECLARE leak uuid;
BEGIN
  SELECT id INTO leak
    FROM orders
   WHERE customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: vendor can read foreign customer order %', leak;
  END IF;
END$$;

-- Customer should not read other companies' orders
set session "request.jwt.claims" = '{"role": "buyer", "company_id": "30000000-0000-0000-0000-000000000000"}';
DO $$
DECLARE leak uuid;
BEGIN
  SELECT id INTO leak
    FROM orders
   WHERE customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: customer can read foreign order %', leak;
  END IF;
END$$;

-- Vendor cross-tenant write attempt should fail
set session "request.jwt.claims" = '{"role": "vendor_admin", "company_id": "20000000-0000-0000-0000-000000000000"}';
DO $$
BEGIN
  UPDATE products
     SET name = name || jsonb_build_object('rls', 'fail')
   WHERE vendor_company_id <> auth_company_id();
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: vendor updated foreign product';
  END IF;
END$$;

-- Customer insert should be scoped to its tenant orders only
set session "request.jwt.claims" = '{"role": "buyer", "company_id": "30000000-0000-0000-0000-000000000000", "sub": "33333333-3333-3333-3333-333333333333"}';
DO $$
DECLARE
  foreign_order uuid;
  foreign_variant uuid;
  foreign_vendor uuid;
BEGIN
  SELECT oi.order_id, oi.variant_id, oi.vendor_company_id
    INTO foreign_order, foreign_variant, foreign_vendor
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
   WHERE o.customer_company_id <> auth_company_id()
   LIMIT 1;

  IF foreign_order IS NULL THEN
    RAISE NOTICE 'Skipping order_items cross-tenant test: no foreign data available';
    RETURN;
  END IF;

  BEGIN
    INSERT INTO order_items(order_id, vendor_company_id, variant_id, qty, uom, unit_price, discount_pct, tax_rate)
    VALUES (foreign_order, foreign_vendor, foreign_variant, 1, 'EA', 1, 0, 17);
    RAISE EXCEPTION 'RLS violation: customer inserted into foreign order';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN raise_exception THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLSTATE <> '42501' THEN
        RAISE;
      END IF;
  END;
END$$;

reset "request.jwt.claims";
reset role;
