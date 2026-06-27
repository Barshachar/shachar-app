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
   where customer_company_id <> auth_company_id();
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
reset session "request.jwt.claims";

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
reset session "request.jwt.claims";

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
reset session "request.jwt.claims";

-- Seed a fresh, non-delivered order for the buyer's company (default role,
-- RLS-exempt) so section 4 can exercise the cashback award guards.
DO $$
BEGIN
  INSERT INTO orders (id, customer_company_id, created_by, status, currency)
  VALUES ('00000000-0000-0000-0000-0000000000f4',
          '30000000-0000-0000-0000-000000000000',
          '33333333-3333-3333-3333-333333333333', 'placed', 'ILS')
  ON CONFLICT (id) DO NOTHING;
END
$$;

-- 4. Customer cannot read another tenant's cashback, credit themselves directly,
-- or earn cashback by self-marking their own order delivered.
-- Guarded so the suite still runs before patch 023_cashback_ledger.sql.
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
  IF to_regclass('public.cashback_ledger') IS NULL THEN
    RETURN;
  END IF;

  SELECT c.id INTO leak
    FROM cashback_ledger c
   WHERE c.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION
      'RLS violation: customer % can read foreign cashback %',
      auth_company_id(), leak;
  END IF;

  BEGIN
    INSERT INTO cashback_ledger (customer_company_id, entry_type, amount, currency)
    VALUES (auth_company_id(), 'earn', 9999.00, 'ILS');

    RAISE EXCEPTION
      'RLS violation: customer % credited its own cashback',
      auth_company_id();
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL; -- expected: no customer write policy exists
    WHEN raise_exception THEN
      RAISE;
    WHEN OTHERS THEN
      IF SQLSTATE <> '42501' THEN
        RAISE;
      END IF;
  END;

  -- Award-path guards (only when the RPC exists, i.e. patch 023 applied).
  IF to_regprocedure('public.rpc_award_order_cashback(uuid)') IS NOT NULL THEN
    -- (a) Direct RPC execution is denied for customers (execute revoked).
    BEGIN
      PERFORM rpc_award_order_cashback('00000000-0000-0000-0000-0000000000f4');
      RAISE EXCEPTION
        'Security violation: buyer executed rpc_award_order_cashback directly';
    EXCEPTION
      WHEN insufficient_privilege THEN
        NULL; -- expected
      WHEN raise_exception THEN
        RAISE;
      WHEN OTHERS THEN
        IF SQLSTATE <> '42501' THEN
          RAISE;
        END IF;
    END;

    -- (b) A customer self-marking their order delivered must not earn cashback.
    UPDATE orders SET status = 'delivered'
     WHERE id = '00000000-0000-0000-0000-0000000000f4';
    IF EXISTS (
      SELECT 1 FROM cashback_ledger
       WHERE order_id = '00000000-0000-0000-0000-0000000000f4'
         AND entry_type = 'earn'
    ) THEN
      RAISE EXCEPTION
        'Security violation: customer self-delivery credited cashback';
    END IF;
  END IF;
END
$$;

reset role;
reset session "request.jwt.claims";

rollback;
-- End of regression tests
