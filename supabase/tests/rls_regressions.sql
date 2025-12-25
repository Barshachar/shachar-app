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

-- 6. Customer cannot read ratings from other customers
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "buyer",
  "company_id": "30000000-0000-0000-0000-000000000000",
  "sub": "33333333-3333-3333-3333-333333333333"
}';

DO $$
DECLARE
  leak_count integer;
BEGIN
  select count(*) into leak_count
    from vendor_ratings
   where customer_company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: customer % saw % foreign vendor ratings',
      auth_company_id(), leak_count;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    INSERT INTO vendor_ratings (
      vendor_company_id,
      customer_company_id,
      order_id,
      rating,
      comment,
      created_by
    )
    VALUES (
      '20000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000000',
      'A0000000-0000-0000-0000-000000000001',
      5,
      'cross tenant probe',
      auth.uid()
    );

    RAISE EXCEPTION
      'RLS violation: customer % inserted rating for foreign order',
      auth_company_id();
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

-- 7. Vendor cannot submit ratings
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_admin",
  "company_id": "20000000-0000-0000-0000-000000000000",
  "sub": "22222222-2222-2222-2222-222222222222"
}';

DO $$
BEGIN
  BEGIN
    INSERT INTO vendor_ratings (
      vendor_company_id,
      customer_company_id,
      order_id,
      rating,
      comment,
      created_by
    )
    VALUES (
      '20000000-0000-0000-0000-000000000000',
      '30000000-0000-0000-0000-000000000000',
      'A0000000-0000-0000-0000-000000000000',
      4,
      'vendor attempt',
      auth.uid()
    );

    RAISE EXCEPTION
      'RLS violation: vendor % inserted rating',
      auth_company_id();
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

DO $$
BEGIN
  BEGIN
    UPDATE orders
       SET status = 'cancelled',
           cancellation_reason = 'rls_probe',
           cancelled_at = now(),
           cancelled_by = auth.uid()
     WHERE id = 'A0000000-0000-0000-0000-000000000001';

    IF FOUND THEN
      RAISE EXCEPTION
        'RLS violation: customer % cancelled foreign order',
        auth_company_id();
    END IF;
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

-- 8. Customer cannot read returns from other customers
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "buyer",
  "company_id": "30000000-0000-0000-0000-000000000000",
  "sub": "33333333-3333-3333-3333-333333333333"
}';

DO $$
DECLARE
  leak_count integer;
BEGIN
  select count(*) into leak_count
    from returns r
    join orders o on o.id = r.order_id
   where o.customer_company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: customer % saw % foreign returns',
      auth_company_id(), leak_count;
  END IF;
END
$$;

reset role;
reset "request.jwt.claims";

-- 9. Vendor cannot read returns for other vendors
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_admin",
  "company_id": "20000000-0000-0000-0000-000000000000",
  "sub": "22222222-2222-2222-2222-222222222222"
}';

DO $$
DECLARE
  leak_count integer;
BEGIN
  select count(*) into leak_count
    from returns r
    join order_items oi on oi.id = r.item_id
   where oi.vendor_company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: vendor % saw % foreign returns',
      auth_company_id(), leak_count;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    INSERT INTO returns (
      order_id,
      item_id,
      reason,
      qty,
      status,
      created_by
    )
    VALUES (
      'A0000000-0000-0000-0000-000000000000',
      'B0000000-0000-0000-0000-000000000000',
      'vendor attempt',
      1,
      'requested',
      auth.uid()
    );

    RAISE EXCEPTION
      'RLS violation: vendor % inserted return',
      auth_company_id();
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

-- 10. Customer cannot read approval requests from other tenants
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
    from approval_requests
   where company_id <> auth_company_id();
  IF leak_count > 0 THEN
    RAISE EXCEPTION
      'RLS violation: customer % saw % foreign approval requests',
      auth_company_id(), leak_count;
  END IF;
END
$$;

DO $$
BEGIN
  BEGIN
    UPDATE approval_requests
       SET status = 'approved'
     WHERE id = 'AA000000-0000-0000-0000-000000000000';

    IF FOUND THEN
      RAISE EXCEPTION
        'RLS violation: customer % updated foreign approval request',
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

rollback;
-- End of regression tests
