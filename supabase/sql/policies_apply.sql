-- Enable Row Level Security on all tables/views
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
alter table if exists storage.objects enable row level security;

-- Companies
create policy companies_admin_all on companies
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy companies_self_select on companies
  for select to authenticated
  using (id = auth_company_id());

-- Company Users
create policy company_users_admin_all on company_users
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy company_users_company_select on company_users
  for select to authenticated
  using (company_id = auth_company_id());

-- Categories
create policy categories_admin_write on categories
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy categories_read_all on categories
  for select to authenticated
  using (true);

-- Attributes
create policy attributes_admin_write on attributes
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy attributes_read_all on attributes
  for select to authenticated
  using (true);

-- Products
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
    auth_role() in ('customer_admin','buyer') and active = true
    or auth_role() in ('vendor_admin','vendor_user')
  );

-- Product Variants
create policy product_variants_admin_all on product_variants
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy product_variants_vendor_rw on product_variants
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from products p
       where p.id = product_variants.product_id
         and p.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from products p
       where p.id = product_variants.product_id
         and p.vendor_company_id = auth_company_id()
    )
  );

create policy product_variants_customer_read on product_variants
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer') and active = true
    or auth_role() in ('vendor_admin','vendor_user')
  );

-- Inventory
create policy inventory_admin_all on inventory
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy inventory_vendor_rw on inventory
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from product_variants pv
        join products p on p.id = pv.product_id
       where pv.id = inventory.variant_id
         and p.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from product_variants pv
        join products p on p.id = pv.product_id
       where pv.id = inventory.variant_id
         and p.vendor_company_id = auth_company_id()
    )
  );

create policy inventory_customer_read on inventory
  for select to authenticated
  using (auth_role() in ('customer_admin','buyer') or auth_role() in ('vendor_admin','vendor_user'));

-- Price Lists
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

-- Prices
create policy prices_admin_all on prices
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy prices_vendor_rw on prices
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from price_lists pl
       where pl.id = prices.price_list_id
         and pl.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from price_lists pl
       where pl.id = prices.price_list_id
         and pl.vendor_company_id = auth_company_id()
    )
  );

create policy prices_customer_read on prices
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from price_lists pl
       where pl.id = prices.price_list_id
         and (
           pl.scope = 'global'
           or pl.target_id = auth_company_id()
         )
    )
  );

-- Orders
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

-- Order Items
create policy order_items_admin_all on order_items
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy order_items_customer_read on order_items
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from orders o
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

create policy order_items_vendor_read on order_items
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

-- Shipments
create policy shipments_admin_all on shipments
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy shipments_customer_read on shipments
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from orders o
       where o.id = shipments.order_id
         and o.customer_company_id = auth_company_id()
    )
  );

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

-- Returns
create policy returns_admin_all on returns
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- Attachments
create policy attachments_admin_all on attachments
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy attachments_owner_rw on attachments
  for all to authenticated
  using (created_by = auth.uid())
  with check (created_by = auth.uid());

-- Notifications
create policy notifications_admin_all on notifications
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy notifications_owner_rw on notifications
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Audit Log
create policy audit_log_admin_read on audit_log
  for select using (auth_role() = 'admin');

-- Storage Objects (Supabase Storage RLS)
create policy storage_admin_read
  on storage.objects for select
  using (auth_role() = 'admin');

create policy storage_admin_all
  on storage.objects for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

-- ----------
-- Negative tests to guard against cross-tenant leakage
-- These DO blocks raise exceptions if RLS permits cross-tenant access.

-- Vendor should not read other customers' orders
set local role authenticated;
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

-- Customer should not read other companies' sensitive data (orders)
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

-- Cross-tenant write attempt should fail (vendor updating another vendor product)
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
      NULL; -- expected due to RLS
    WHEN raise_exception THEN
      RAISE; -- propagate explicit failures
    WHEN OTHERS THEN
      -- ensure we only swallow typical RLS errors
      IF SQLSTATE <> '42501' THEN
        RAISE;
      END IF;
  END;

  -- cleanup in case insert somehow succeeded before exception;
END$$;

reset session "request.jwt.claims";
reset role;
