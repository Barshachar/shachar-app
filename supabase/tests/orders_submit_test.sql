\set ON_ERROR_STOP on

begin;

-- Seed a draft order scoped to company 3000...
insert into orders (id, customer_company_id, created_by, status, currency, created_at)
values (
  'F0000000-0000-0000-0000-000000000000',
  '30000000-0000-0000-0000-000000000000',
  '33333333-3333-3333-3333-333333333333',
  'draft',
  'ILS',
  now()
);

insert into order_items (id, order_id, vendor_company_id, variant_id, qty, uom, unit_price, tax_rate, discount_pct)
values
  (
    'F1000000-0000-0000-0000-000000000000',
    'F0000000-0000-0000-0000-000000000000',
    '20000000-0000-0000-0000-000000000000',
    '70000000-0000-0000-0000-000000000000',
    4,
    'KG',
    0,
    0,
    0
  ),
  (
    'F1000000-0000-0000-0000-000000000001',
    'F0000000-0000-0000-0000-000000000000',
    '20000000-0000-0000-0000-000000000001',
    '70000000-0000-0000-0000-000000000002',
    10,
    'EA',
    0,
    0,
    0
  );

-- Buyer scope submits draft
set local role authenticated;
set session "request.jwt.claims" = '{
  "role": "buyer",
  "company_id": "30000000-0000-0000-0000-000000000000",
  "sub": "33333333-3333-3333-3333-333333333333"
}';

select rpc_submit_order('F0000000-0000-0000-0000-000000000000');

-- Verify totals and status
do $$
declare
  v_status text;
  v_total numeric;
begin
  select status, total into v_status, v_total
    from orders
   where id = 'F0000000-0000-0000-0000-000000000000';

  if v_status <> 'placed' then
    raise exception 'Order status % did not transition to placed', v_status;
  end if;

  if v_total <= 0 then
    raise exception 'Order total % invalid after submit_order', v_total;
  end if;
end
$$;

-- Audit log should capture submission
do $$
declare
  audit_count integer;
begin
  select count(*) into audit_count
    from audit_log
   where table_name = 'orders'
     and row_id = 'F0000000-0000-0000-0000-000000000000'
     and action = 'order_submitted';
  if audit_count <> 1 then
    raise exception 'Audit log missing entry for draft order submit';
  end if;
end
$$;

rollback;
