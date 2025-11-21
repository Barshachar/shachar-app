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
set role supabase_storage_admin;
alter table if exists storage.objects enable row level security;
reset role;
alter table cost_centers enable row level security;
alter table payment_terms_templates enable row level security;
alter table vendor_payment_term_settings enable row level security;
alter table vendor_payment_term_options enable row level security;
alter table vendor_payment_term_overrides enable row level security;
alter table warehouses enable row level security;
alter table warehouse_zones enable row level security;
alter table warehouse_bins enable row level security;
alter table support_tickets enable row level security;
alter table customer_profiles enable row level security;
alter table vendor_metrics enable row level security;
alter table saved_lists enable row level security;
alter table saved_list_items enable row level security;
alter table payment_events enable row level security;

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

-- Cost Centers
create policy cost_centers_admin_all on cost_centers
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy cost_centers_customer_read on cost_centers
  for select to authenticated
  using (
    company_id = auth_company_id()
    and auth_role() in ('customer_admin','buyer')
  );

create policy cost_centers_customer_manage on cost_centers
  for all to authenticated
  using (
    company_id = auth_company_id()
    and auth_role() = 'customer_admin'
  )
  with check (
    company_id = auth_company_id()
    and auth_role() = 'customer_admin'
  );

-- Payment terms templates (admin only)
create policy payment_terms_templates_admin_all on payment_terms_templates
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- Vendor payment terms
create policy vendor_payment_term_settings_admin_all on vendor_payment_term_settings
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy vendor_payment_term_settings_vendor_manage on vendor_payment_term_settings
  for all to authenticated
  using (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  );

create policy vendor_payment_term_options_admin_all on vendor_payment_term_options
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy vendor_payment_term_options_vendor_manage on vendor_payment_term_options
  for all to authenticated
  using (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  );

create policy vendor_payment_term_overrides_admin_all on vendor_payment_term_overrides
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy vendor_payment_term_overrides_vendor_manage on vendor_payment_term_overrides
  for all to authenticated
  using (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  );

-- Warehouses
create policy warehouses_admin_all on warehouses
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy warehouses_vendor_manage on warehouses
  for all to authenticated
  using (
    company_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    company_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  );

create policy warehouse_zones_admin_all on warehouse_zones
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy warehouse_zones_vendor_manage on warehouse_zones
  for all to authenticated
  using (
    exists (
      select 1
        from warehouses w
       where w.id = warehouse_zones.warehouse_id
         and w.company_id = auth_company_id()
    )
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    exists (
      select 1
        from warehouses w
       where w.id = warehouse_zones.warehouse_id
         and w.company_id = auth_company_id()
    )
    and auth_role() in ('vendor_admin','vendor_user')
  );

create policy warehouse_bins_admin_all on warehouse_bins
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy warehouse_bins_vendor_manage on warehouse_bins
  for all to authenticated
  using (
    exists (
      select 1
        from warehouse_zones wz
        join warehouses w on w.id = wz.warehouse_id
       where wz.id = warehouse_bins.zone_id
         and w.company_id = auth_company_id()
    )
    and auth_role() in ('vendor_admin','vendor_user')
  )
  with check (
    exists (
      select 1
        from warehouse_zones wz
        join warehouses w on w.id = wz.warehouse_id
       where wz.id = warehouse_bins.zone_id
         and w.company_id = auth_company_id()
    )
    and auth_role() in ('vendor_admin','vendor_user')
  );

-- Support tickets
create policy support_tickets_admin_all on support_tickets
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy support_tickets_company_access on support_tickets
  for all to authenticated
  using (
    company_id = auth_company_id()
    and auth_role() in ('customer_admin','buyer','vendor_admin','vendor_user')
  )
  with check (
    company_id = auth_company_id()
    and auth_role() in ('customer_admin','vendor_admin')
  );

-- Customer profiles
create policy customer_profiles_admin_all on customer_profiles
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy customer_profiles_company_access on customer_profiles
  for select to authenticated
  using (
    customer_id = auth_company_id()
    and auth_role() in ('customer_admin','buyer')
  );

-- Vendor metrics
create policy vendor_metrics_admin_all on vendor_metrics
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy vendor_metrics_company_access on vendor_metrics
  for select to authenticated
  using (
    vendor_id = auth_company_id()
    and auth_role() in ('vendor_admin','vendor_user')
  );

-- Payment events
create policy payment_events_admin_all on payment_events
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

-- Saved lists
create policy saved_lists_admin_all on saved_lists
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy saved_lists_company_access on saved_lists
  for all to authenticated
  using (
    customer_id = auth_company_id()
    and auth_role() in ('customer_admin','buyer')
  )
  with check (
    customer_id = auth_company_id()
    and auth_role() in ('customer_admin','buyer')
  );

create policy saved_list_items_admin_all on saved_list_items
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy saved_list_items_company_access on saved_list_items
  for all to authenticated
  using (
    exists (
      select 1
        from saved_lists sl
       where sl.id = saved_list_items.list_id
         and sl.customer_id = auth_company_id()
    )
    and auth_role() in ('customer_admin','buyer')
  )
  with check (
    exists (
      select 1
        from saved_lists sl
       where sl.id = saved_list_items.list_id
         and sl.customer_id = auth_company_id()
    )
    and auth_role() in ('customer_admin','buyer')
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

create policy audit_log_customer_orders_read on audit_log
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and table_name = 'orders'
    and exists (
      select 1
        from orders o
       where o.id = audit_log.row_id
         and o.customer_company_id = auth_company_id()
    )
  );

-- Storage Objects (Supabase Storage RLS)
set role supabase_storage_admin;
set search_path = public, storage;
create policy storage_admin_read
  on storage.objects for select
  using (auth_role() = 'admin');

create policy storage_admin_all
  on storage.objects for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');
reset search_path;
reset role;

-- Assertions moved to supabase/tests/rls_assertions.sql
