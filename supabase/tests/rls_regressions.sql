-- RLS regression tests for multi-tenant isolation
-- Run against a database that has loaded schema.sql, policies.sql, and seed.sql

begin;

-- Helper to switch context for a JWT-authenticated user
-- Example claim payload reference:
--   role: auth role string ('vendor_admin', 'buyer', etc)
--   company_id: UUID of tenant company

-- 1. Vendor cannot view or update customer orders outside their vendor scope
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_admin",
  "company_id": "20000000-0000-0000-0000-000000000000",
  "sub": "22222222-2222-2222-2222-222222222222"
}';

DO $$
DECLARE
  unauthorized_count integer;
BEGIN
  select count(*) into unauthorized_count
    from orders
   where not order_has_vendor(id, auth_company_id());
  IF unauthorized_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: vendor company % can see % foreign orders',
      auth_company_id(), unauthorized_count;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    update products
       set name = name || jsonb_build_object('rls_probe', 'fail')
     where vendor_company_id <> auth_company_id();

    IF FOUND THEN
      RAISE EXCEPTION
        'RLS violation: vendor % updated foreign product',
        auth_company_id();
    END IF;
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL; -- expected due to RLS
    WHEN raise_exception THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLSTATE <> '42501' THEN
        RAISE;
      END IF;
  END;
END
$$;

reset role;
reset "request.jwt.claims";

-- 2. Customer cannot access orders belonging to another customer tenant
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "buyer",
  "company_id": "30000000-0000-0000-0000-000000000000",
  "sub": "33333333-3333-3333-3333-333333333333"
}';

DO $$
DECLARE
  leak uuid;
BEGIN
  SELECT o.id INTO leak
    FROM orders o
   WHERE o.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION
      'RLS violation: customer % can read foreign order %',
      auth_company_id(), leak;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    INSERT INTO orders (customer_company_id, created_by, status, currency)
    VALUES ('30000000-0000-0000-0000-000000000001', auth.uid(), 'draft', 'ILS');

    RAISE EXCEPTION
      'RLS violation: customer % inserted order for foreign tenant',
      auth_company_id();
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL; -- expected failure
    WHEN raise_exception THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLSTATE <> '42501' THEN
        RAISE;
      END IF;
  END;
END
$$;

reset role;
reset "request.jwt.claims";

-- 3. Vendor cannot mutate price lists for another vendor tenant
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_admin",
  "company_id": "20000000-0000-0000-0000-000000000001",
  "sub": "22222222-2222-2222-2222-222222222223"
}';

DO $$
BEGIN
  BEGIN
    UPDATE price_lists
       SET name = name || ' ⚠'
     WHERE vendor_company_id <> auth_company_id();

    IF FOUND THEN
      RAISE EXCEPTION
        'RLS violation: vendor % mutated foreign price list',
        auth_company_id();
    END IF;
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
END
$$;

reset role;
reset "request.jwt.claims";

-- 4. Vendor cannot enumerate company_users outside its tenant
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_user",
  "company_id": "20000000-0000-0000-0000-000000000000",
  "sub": "22222222-2222-2222-2222-222222222222"
}';

DO $$
DECLARE
  leak_count integer;
BEGIN
  select count(*) into leak_count
    from company_users
   where company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: vendor % enumerated % foreign company_users',
      auth_company_id(), leak_count;
  END IF;
END
$$;

reset role;
reset "request.jwt.claims";

-- 5. Customer cannot read inventory rows for other vendors
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "customer_admin",
  "company_id": "30000000-0000-0000-0000-000000000001",
  "sub": "33333333-3333-3333-3333-333333333334"
}';

DO $$
DECLARE
  leak_count integer;
BEGIN
  select count(*) into leak_count
    from inventory i
    join product_variants pv on pv.id = i.variant_id
    join products p on p.id = pv.product_id
   where p.vendor_company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: customer % saw % foreign inventory rows',
      auth_company_id(), leak_count;
  END IF;
END
$$;

reset role;
reset "request.jwt.claims";

rollback;
-- End of regression tests
