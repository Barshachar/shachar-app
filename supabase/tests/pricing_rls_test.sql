\set ON_ERROR_STOP on

begin;

-- Vendor scope should only see its own effective prices
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "vendor_admin",
  "company_id": "20000000-0000-0000-0000-000000000000",
  "sub": "22222222-2222-2222-2222-222222222222"
}';

do $$
declare
  leaks integer;
begin
  select count(*) into leaks
    from secure_effective_prices
   where vendor_id <> auth_company_id();
  if leaks > 0 then
    raise exception
      'Vendor % saw % foreign price rows in secure_effective_prices',
      auth_company_id(), leaks;
  end if;
end
$$;

reset role;
reset "request.jwt.claims";

-- Customer scope should never see another tenant's customer-specific rows
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "buyer",
  "company_id": "30000000-0000-0000-0000-000000000000",
  "sub": "33333333-3333-3333-3333-333333333333"
}';

do $$
declare
  leaks integer;
begin
  select count(*) into leaks
    from secure_effective_prices
   where scope = 'customer'
     and customer_id <> auth_company_id();
  if leaks > 0 then
    raise exception
      'Customer % saw % foreign scoped prices',
      auth_company_id(), leaks;
  end if;
end
$$;

reset role;
reset "request.jwt.claims";

rollback;
