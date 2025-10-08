-- Enable RLS on all tables
alter table companies enable row level security;
alter table company_users enable row level security;
alter table categories enable row level security;
alter table attributes enable row level security;
alter table products enable row level security;
alter table product_variants enable row level security;
alter table inventory enable row level security;
alter table price_lists enable row level security;
alter table prices enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table shipments enable row level security;
alter table returns enable row level security;
alter table attachments enable row level security;
alter table notifications enable row level security;
alter table audit_log enable row level security;

-- Companies policies
create policy companies_admin_all on companies
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

create policy companies_self_select on companies
  for select
  using (id = auth_company_id());

-- Company users policies
create policy company_users_admin_all on company_users
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

create policy company_users_company_select on company_users
  for select
  using (company_id = auth_company_id());

-- Categories & attributes (global read, admin writes)
create policy categories_read_all on categories
  for select using (true);
create policy categories_admin_write on categories
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy attributes_read_all on attributes
  for select using (true);
create policy attributes_admin_write on attributes
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- Products policies
create policy products_admin_all on products
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy products_vendor_rw on products
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

create policy products_customer_read on products
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and active = true
  );

-- Product variants policies
create policy variants_admin_all on product_variants
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy variants_vendor_rw on product_variants
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from products p
       where p.id = product_variants.product_id
         and p.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from products p
       where p.id = product_variants.product_id
         and p.vendor_company_id = auth_company_id()
    )
  );

create policy variants_customer_read on product_variants
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and active = true
  );

-- Inventory policies
create policy inventory_admin_all on inventory
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy inventory_vendor_rw on inventory
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from product_variants pv
       join products p on p.id = pv.product_id
      where pv.id = inventory.variant_id
        and p.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from product_variants pv
       join products p on p.id = pv.product_id
      where pv.id = inventory.variant_id
        and p.vendor_company_id = auth_company_id()
    )
  );

create policy inventory_customer_read on inventory
  for select to authenticated
  using (auth_role() in ('customer_admin','buyer'));

-- Price lists policies
create policy price_lists_admin_all on price_lists
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy price_lists_vendor_rw on price_lists
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

create policy price_lists_customer_read on price_lists
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and (
      scope = 'global'
      or target_id = auth_company_id()
    )
  );

-- Prices policies
create policy prices_admin_all on prices
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy prices_vendor_rw on prices
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from price_lists pl
      where pl.id = prices.price_list_id
        and pl.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1 from price_lists pl
      where pl.id = prices.price_list_id
        and pl.vendor_company_id = auth_company_id()
    )
  );

create policy prices_customer_read on prices
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1 from price_lists pl
      where pl.id = prices.price_list_id
        and (
          pl.scope = 'global' or pl.target_id = auth_company_id()
        )
    )
  );

-- Orders policies
create policy orders_admin_all on orders
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy orders_customer_rw on orders
  for all to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

create policy orders_vendor_read on orders
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and order_has_vendor(orders.id, auth_company_id())
  );

-- Order items policies
create policy order_items_admin_all on order_items
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy order_items_vendor_rw on order_items
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

create policy order_items_customer_read on order_items
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1 from orders o
      where o.id = order_items.order_id
        and o.customer_company_id = auth_company_id()
    )
  );

create policy order_items_customer_insert on order_items
  for insert to authenticated
  with check (
    auth_role() in ('customer_admin','buyer')
    and order_item_customer_guard(order_items.order_id)
  );

-- Shipments
create policy shipments_admin_all on shipments
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy shipments_vendor_rw on shipments
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

create policy shipments_customer_read on shipments
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1 from orders o
      where o.id = shipments.order_id
        and o.customer_company_id = auth_company_id()
    )
  );

-- Returns (feature flag: admin only for now)
create policy returns_admin_only on returns
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- Attachments
create policy attachments_admin_all on attachments
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy attachments_owner_rw on attachments
  for all to authenticated
  using (created_by = auth.uid())
  with check (created_by = auth.uid());

-- Notifications
create policy notifications_owner_rw on notifications
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Audit log
create policy audit_log_admin_read on audit_log
  for select using (auth_role() = 'admin');

-- Secure views for vendors
create or replace view v_vendor_order_headers with (security_barrier=true) as
select o.*
from orders o
where auth_role() = 'admin'
   or exists (
     select 1 from order_items oi
      where oi.order_id = o.id
        and oi.vendor_company_id = auth_company_id()
   );

-- Negative Tests (fail if RLS leaks data)
-- Customer cannot read other customer's orders
set local role authenticated;
set session "request.jwt.claims" = '{"role": "buyer", "company_id": "00000000-0000-0000-0000-000000000001"}';
DO $$
DECLARE leak uuid;
BEGIN
  SELECT id INTO leak FROM orders WHERE customer_company_id <> '00000000-0000-0000-0000-000000000001' LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: buyer sees other tenant order %', leak;
  END IF;
END$$;

-- Vendor cannot modify other vendor product
set session "request.jwt.claims" = '{"role": "vendor_admin", "company_id": "00000000-0000-0000-0000-000000000002"}';
DO $$
DECLARE ok boolean;
BEGIN
  UPDATE products SET name = name || jsonb_build_object('test', 'fail')
   WHERE vendor_company_id <> '00000000-0000-0000-0000-000000000002';
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: vendor modified foreign product';
  END IF;
END$$;

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

reset session "request.jwt.claims";
reset role;
