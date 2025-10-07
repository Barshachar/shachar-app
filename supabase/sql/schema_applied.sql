-- Supabase schema for א.שחר B2B Marketplace
set check_function_bodies = off;

create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;
create extension if not exists pg_trgm;
create extension if not exists btree_gin;

create type company_type as enum ('admin','vendor','customer');
create type company_status as enum ('pending','active','suspended','rejected');
create type user_role as enum ('admin','vendor_admin','vendor_user','customer_admin','buyer');
create type price_list_scope as enum ('global','customer');
create type order_status as enum ('draft','placed','confirmed','picking','shipped','delivered','cancelled');
create type shipment_status as enum ('pending','ready','in_transit','delivered','cancelled');

create table companies (
    id uuid primary key default uuid_generate_v4(),
    type company_type not null,
    status company_status not null default 'pending',
    name text not null,
    locale text not null default 'he',
    currency text not null default 'ILS',
    timezone text not null default 'Asia/Jerusalem',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table company_users (
    company_id uuid not null references companies(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,
    role user_role not null,
    created_at timestamptz not null default now(),
    primary key (company_id, user_id)
);

create index company_users_user_idx on company_users (user_id);
create index company_users_role_idx on company_users (role);

create view users as
select u.id,
       u.email,
       u.created_at,
       coalesce(u.raw_user_meta_data->>'locale', 'he') as locale
  from auth.users u;

drop view if exists user_companies cascade;
create view user_companies as
select cu.user_id,
       cu.company_id,
       c.type,
       cu.role
  from company_users cu
  join companies c on c.id = cu.company_id;

create table categories (
    id uuid primary key default uuid_generate_v4(),
    parent_id uuid null references categories(id) on delete set null,
    name jsonb not null,
    sort_order int not null default 0,
    created_at timestamptz not null default now()
);
create index categories_parent_idx on categories(parent_id);

create table attributes (
    id uuid primary key default uuid_generate_v4(),
    code text not null unique,
    name jsonb not null,
    type text not null,
    created_at timestamptz not null default now()
);

create table products (
    id uuid primary key default uuid_generate_v4(),
    vendor_company_id uuid not null references companies(id) on delete cascade,
    category_id uuid null references categories(id) on delete set null,
    sku text not null unique,
    name jsonb not null,
    description jsonb,
    uom text not null default 'EA',
    pack_size int not null default 1,
    moq int not null default 1,
    lead_time int not null default 0,
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index products_vendor_active_idx on products(vendor_company_id, active);
create index products_name_trgm_idx on products using gin ((name->>'he') gin_trgm_ops);

create table product_variants (
    id uuid primary key default uuid_generate_v4(),
    product_id uuid not null references products(id) on delete cascade,
    attributes_json jsonb not null,
    sku text not null,
    barcode text,
    uom text not null default 'EA',
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique(product_id, sku)
);
create index product_variants_barcode_idx on product_variants(barcode);
create index product_variants_sku_idx on product_variants(sku);

create table inventory (
    variant_id uuid primary key references product_variants(id) on delete cascade,
    qty numeric(14,3) not null default 0,
    low_stock_threshold numeric(14,3) not null default 0,
    updated_at timestamptz not null default now()
);

create table price_lists (
    id uuid primary key default uuid_generate_v4(),
    vendor_company_id uuid not null references companies(id) on delete cascade,
    scope price_list_scope not null,
    target_id uuid null,
    name text not null,
    valid_from timestamptz not null default now(),
    valid_to timestamptz null,
    priority int not null default 100,
    currency text not null default 'ILS',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (vendor_company_id, name)
);
create index price_lists_scope_idx on price_lists(scope, target_id);

create table prices (
    id uuid primary key default uuid_generate_v4(),
    price_list_id uuid not null references price_lists(id) on delete cascade,
    variant_id uuid not null references product_variants(id) on delete cascade,
    min_qty int not null default 1,
    unit_price numeric(12,2) not null,
    created_at timestamptz not null default now()
);
create unique index prices_unique_idx on prices(price_list_id, variant_id, min_qty);

create materialized view mv_effective_prices as
select
    pl.scope,
    pl.vendor_company_id as vendor_id,
    case when pl.scope = 'customer' then pl.target_id else null end as customer_id,
    pr.variant_id,
    pr.unit_price,
    pr.min_qty,
    pl.priority,
    pl.currency,
    pl.valid_from,
    pl.valid_to
from price_lists pl
join prices pr on pr.price_list_id = pl.id
where pl.valid_from <= now()
  and (pl.valid_to is null or pl.valid_to >= now());

create unique index mv_effective_prices_idx on mv_effective_prices(vendor_id, coalesce(customer_id, '00000000-0000-0000-0000-000000000000'::uuid), variant_id, min_qty);

create table orders (
    id uuid primary key default uuid_generate_v4(),
    customer_company_id uuid not null references companies(id) on delete cascade,
    created_by uuid not null references auth.users(id),
    status order_status not null default 'draft',
    delivery_window daterange,
    notes text,
    currency text not null default 'ILS',
    subtotal numeric(14,2) not null default 0,
    tax_total numeric(14,2) not null default 0,
    total numeric(14,2) not null default 0,
    order_number text generated always as (upper(replace(id::text, '-', ''))) stored,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index orders_company_status_idx on orders(customer_company_id, status);
create index orders_created_at_idx on orders(created_at desc);

create table order_items (
    id uuid primary key default uuid_generate_v4(),
    order_id uuid not null references orders(id) on delete cascade,
    vendor_company_id uuid not null references companies(id) on delete cascade,
    variant_id uuid not null references product_variants(id) on delete cascade,
    qty numeric(14,3) not null,
    uom text not null default 'EA',
    unit_price numeric(12,2) not null,
    discount_pct numeric(5,2) not null default 0,
    tax_rate numeric(5,2) not null default 17.00,
    line_total numeric(14,2) generated always as ((unit_price * qty) * (1 - discount_pct / 100) * (1 + tax_rate / 100)) stored
);
create index order_items_order_idx on order_items(order_id);
create index order_items_vendor_idx on order_items(vendor_company_id);

create table shipments (
    id uuid primary key default uuid_generate_v4(),
    order_id uuid not null references orders(id) on delete cascade,
    vendor_company_id uuid not null references companies(id) on delete cascade,
    status shipment_status not null default 'pending',
    tracking text,
    partial_flag boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table returns (
    id uuid primary key default uuid_generate_v4(),
    order_id uuid not null references orders(id) on delete cascade,
    item_id uuid not null references order_items(id) on delete cascade,
    reason text,
    qty numeric(14,3) not null,
    created_at timestamptz not null default now()
);

create table promotions (
    id uuid primary key default uuid_generate_v4(),
    title jsonb not null,
    description jsonb,
    badge_label jsonb not null,
    terms jsonb,
    tags text[] default array[]::text[],
    image_url text,
    valid_from timestamptz not null default now(),
    valid_to timestamptz not null,
    active boolean not null default true,
    priority int not null default 100,
    target_customer_ids uuid[] default array[]::uuid[],
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index promotions_active_dates_idx on promotions(active, valid_from, valid_to);
create index promotions_priority_idx on promotions(priority desc);

create table promotion_products (
    id uuid primary key default uuid_generate_v4(),
    promotion_id uuid not null references promotions(id) on delete cascade,
    product_id uuid not null references products(id) on delete cascade,
    discount_pct numeric(5,2) not null default 0,
    special_price numeric(12,2),
    created_at timestamptz not null default now(),
    unique(promotion_id, product_id)
);
create index promotion_products_promotion_idx on promotion_products(promotion_id);

create table approval_requests (
    id uuid primary key default uuid_generate_v4(),
    requester_user_id uuid not null references auth.users(id) on delete cascade,
    approver_user_id uuid not null references auth.users(id) on delete cascade,
    company_id uuid not null references companies(id) on delete cascade,
    request_type text not null,
    entity_type text not null,
    entity_id uuid not null,
    status text not null default 'pending',
    notes text,
    reviewed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create index approval_requests_approver_status_idx on approval_requests(approver_user_id, status);
create index approval_requests_company_idx on approval_requests(company_id);

create table attachments (
    id uuid primary key default uuid_generate_v4(),
    owner_table text not null,
    owner_id uuid not null,
    file_url text not null,
    type text not null,
    created_by uuid not null references auth.users(id),
    created_at timestamptz not null default now()
);
create index attachments_owner_idx on attachments(owner_table, owner_id);

create table notifications (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references auth.users(id) on delete cascade,
    title text not null,
    body text not null,
    data jsonb,
    read_at timestamptz,
    created_at timestamptz not null default now()
);
create index notifications_user_idx on notifications(user_id, read_at);

create table audit_log (
    id uuid primary key default uuid_generate_v4(),
    actor_user_id uuid not null references auth.users(id),
    action text not null,
    table_name text not null,
    row_id uuid,
    metadata jsonb,
    created_at timestamptz not null default now()
);
create index audit_log_table_idx on audit_log(table_name, created_at desc);

-- Helper functions
create or replace function auth_company_id() returns uuid
  language plpgsql
  security definer
  set search_path = public, auth
as $$
declare
  claims jsonb := current_setting('request.jwt.claims', true)::jsonb;
  claim_company uuid;
  fallback uuid;
begin
  if claims ? 'app_metadata' then
    claim_company := (claims->'app_metadata'->>'company_id')::uuid;
    if claim_company is not null then
      return claim_company;
    end if;
  end if;

  if claims ? 'company_id' then
    claim_company := (claims->>'company_id')::uuid;
    if claim_company is not null then
      return claim_company;
    end if;
  end if;

  select cu.company_id
    into fallback
    from public.company_users cu
   where cu.user_id = auth.uid()
   limit 1;

  return fallback;
end;
$$;

grant execute on function auth_company_id() to authenticated, anon, service_role;

create or replace function auth_role() returns user_role
  language plpgsql
  security definer
  set search_path = public, auth
as $$
declare
  claims jsonb := current_setting('request.jwt.claims', true)::jsonb;
  claim_role user_role;
  fallback user_role;
begin
  if claims ? 'app_metadata' then
    begin
      claim_role := (claims->'app_metadata'->>'role')::user_role;
      if claim_role is not null then
        return claim_role;
      end if;
    exception
      when others then null;
    end;
  end if;

  if claims ? 'role' then
    begin
      claim_role := (claims->>'role')::user_role;
      if claim_role is not null then
        return claim_role;
      end if;
    exception
      when others then null;
    end;
  end if;

  select cu.role
    into fallback
    from public.company_users cu
   where cu.user_id = auth.uid()
   limit 1;

  return fallback;
end;
$$;

grant execute on function auth_role() to authenticated, anon, service_role;
create or replace function order_has_vendor(p_order_id uuid, p_vendor uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
      from public.order_items oi
     where oi.order_id = p_order_id
       and oi.vendor_company_id = p_vendor
  );
$$;

grant execute on function order_has_vendor(uuid, uuid) to authenticated, service_role;

create or replace function order_item_customer_guard(p_order_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_company uuid;
  v_auth uuid := auth_company_id();
  v_role text := current_setting('request.jwt.claims', true)::json->>'role';
begin
  select customer_company_id into v_company
    from public.orders
   where id = p_order_id;

  if v_auth is null then
    raise exception 'auth_company_id() is null for role %', v_role using errcode = '42501';
  end if;

  if v_company is null then
    raise exception 'order % not visible (company null) for role %', p_order_id, v_role using errcode = '42501';
  end if;

  if v_company <> v_auth then
    raise exception 'order % belongs to % but auth has %', p_order_id, v_company, v_auth using errcode = '42501';
  end if;

  return true;
end;
$$;

grant execute on function order_item_customer_guard(uuid) to authenticated, service_role;

create or replace function is_role(target text) returns boolean as $$
  select coalesce((current_setting('request.jwt.claims', true)::json->>'role') = target, false);
$$ language sql stable;

-- RPC: ensure draft order exists for current customer user
create or replace function rpc_create_draft()
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user uuid := auth.uid();
  v_company uuid := auth_company_id();
  v_existing uuid;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_company is null then
    raise exception 'Company context missing';
  end if;

  select id
    into v_existing
    from orders
   where status = 'draft'
     and customer_company_id = v_company
     and created_by = v_user
   order by created_at desc
   limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  insert into orders (customer_company_id, created_by, status, currency)
  values (v_company, v_user, 'draft', 'ILS')
  returning id into v_existing;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (v_user, 'order_draft_created', 'orders', v_existing, jsonb_build_object('currency', 'ILS'));

  return v_existing;
end;
$$;

grant execute on function rpc_create_draft() to authenticated, service_role;

-- Refresh MV function
create or replace function refresh_mv_effective_prices() returns void as $$
begin
  refresh materialized view mv_effective_prices;
end;
$$ language plpgsql;

-- Trigger to refresh MV after price changes
create or replace function notify_price_change() returns trigger as $$
begin
  perform refresh_mv_effective_prices();
  return new;
end;
$$ language plpgsql;

create trigger price_lists_refresh_mv
after insert or update or delete on price_lists
for each statement execute function notify_price_change();

create trigger prices_refresh_mv
after insert or update or delete on prices
for each statement execute function notify_price_change();

-- View to expose vendor order summaries without leaking customer data
create or replace view v_vendor_orders as
select
  oi.vendor_company_id,
  o.id as order_id,
  o.order_number,
  o.status,
  o.created_at,
  sum(oi.line_total) as vendor_total
from order_items oi
join orders o on o.id = oi.order_id
group by oi.vendor_company_id, o.id;

create view secure_effective_prices with (security_barrier=true) as
select *
from mv_effective_prices
where auth_role() = 'admin'
   or (vendor_id = auth_company_id() and auth_role() in ('vendor_admin','vendor_user'))
   or (scope = 'customer' and customer_id = auth_company_id() and auth_role() in ('customer_admin','buyer'))
   or (scope = 'global' and auth_role() in ('customer_admin','buyer'));

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on all tables in schema public to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;
grant execute on all functions in schema public to anon, authenticated;

alter default privileges in schema public
  grant select, insert, update, delete on tables to anon, authenticated;
alter default privileges in schema public
  grant usage, select on sequences to anon, authenticated;
alter default privileges in schema public
  grant execute on functions to anon, authenticated;
-- Ensure storage buckets exist
insert into storage.buckets (id, name, public)
values
  ('kyc_docs', 'kyc_docs', false),
  ('attachments', 'attachments', false)
on conflict (id) do nothing;
-- RPC: Resolve effective price
create or replace function rpc_effective_price(p_customer uuid, p_variant uuid, p_qty numeric)
returns table(unit_price numeric, currency text, price_list_scope price_list_scope, vendor_id uuid) as $$
  select ep.unit_price,
         ep.currency,
         ep.scope,
         ep.vendor_id
    from secure_effective_prices ep
   where ep.variant_id = p_variant
     and ep.min_qty <= coalesce(p_qty, 1)
     and (
       (ep.scope = 'customer' and ep.customer_id = p_customer)
       or (ep.scope = 'global')
     )
   order by case when ep.scope = 'customer' then 1 else 2 end,
            ep.priority,
            ep.min_qty desc
   limit 1;
$$ language sql stable;

-- RPC: submit order (draft -> placed)
create or replace function rpc_submit_order(p_order_id uuid)
returns uuid as $$
declare
  v_customer uuid;
  v_auth_company uuid := auth_company_id();
  v_role user_role := auth_role();
  v_record record;
  v_subtotal numeric := 0;
  v_tax numeric := 0;
  v_total numeric := 0;
  v_unit_price numeric;
begin
  select customer_company_id into v_customer
    from orders
   where id = p_order_id
     and status = 'draft'
     for update;

  if not found then
    raise exception 'Order % not found or not draft', p_order_id;
  end if;

  if v_role not in ('customer_admin','buyer','admin') then
    raise exception 'Only customer or admin may submit order';
  end if;

  if v_role <> 'admin' and v_customer <> v_auth_company then
    raise exception 'Tenant violation';
  end if;

  for v_record in
    select oi.id,
           oi.vendor_company_id,
           oi.variant_id,
           oi.qty
      from order_items oi
     where oi.order_id = p_order_id
  loop
    select unit_price
      into v_unit_price
      from rpc_effective_price(v_customer, v_record.variant_id, v_record.qty)
     limit 1;

    if v_unit_price is null then
      raise exception 'Missing price for variant %', v_record.variant_id;
    end if;

    update order_items
       set unit_price = v_unit_price,
           tax_rate = 17.00
     where id = v_record.id;
  end loop;

  select coalesce(sum(unit_price * qty * (1 - discount_pct / 100)), 0),
         coalesce(sum((unit_price * qty * (1 - discount_pct / 100)) * (tax_rate / 100)), 0),
         coalesce(sum(line_total), 0)
    into v_subtotal, v_tax, v_total
    from order_items
   where order_id = p_order_id;

  update orders
     set status = 'placed',
         subtotal = v_subtotal,
         tax_total = v_tax,
         total = v_total,
         updated_at = now()
   where id = p_order_id;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (auth.uid(), 'order_submitted', 'orders', p_order_id, jsonb_build_object('total', v_total));

  return p_order_id;
end;
$$ language plpgsql security definer set search_path = public, auth;

-- RPC: parse and upsert prices from csv payload
create or replace function rpc_upsert_prices(p_vendor uuid, p_rows jsonb)
returns int as $$
declare
  v_row jsonb;
  v_count int := 0;
  v_price_list uuid;
  v_scope price_list_scope;
  v_target uuid;
  v_variant uuid;
  v_price numeric;
  v_min_qty int;
  v_currency text;
begin
  if auth_role() not in ('admin','vendor_admin') then
    raise exception 'Insufficient role';
  end if;

  for v_row in select * from jsonb_array_elements(p_rows)
  loop
    v_scope := coalesce((v_row->>'scope')::price_list_scope, 'global');
    v_target := (v_row->>'customer_id')::uuid;
    v_variant := (v_row->>'variant_id')::uuid;
    v_price := (v_row->>'unit_price')::numeric;
    v_min_qty := coalesce((v_row->>'min_qty')::int, 1);
    v_currency := coalesce(v_row->>'currency', 'ILS');

    select id into v_price_list
      from price_lists
     where vendor_company_id = p_vendor
       and scope = v_scope
       and coalesce(target_id, '00000000-0000-0000-0000-000000000000'::uuid) = coalesce(v_target, '00000000-0000-0000-0000-000000000000'::uuid)
     limit 1;

    if v_price_list is null then
      insert into price_lists(vendor_company_id, scope, target_id, name, priority, currency)
      values (p_vendor, v_scope, v_target, concat('Imported ', now()), 100, v_currency)
      returning id into v_price_list;
    end if;

    insert into prices(price_list_id, variant_id, min_qty, unit_price)
    values (v_price_list, v_variant, v_min_qty, v_price)
    on conflict (price_list_id, variant_id, min_qty)
    do update set unit_price = excluded.unit_price;

    v_count := v_count + 1;
  end loop;

  perform refresh_mv_effective_prices();
  return v_count;
end;
$$ language plpgsql security definer set search_path = public, auth;
create or replace function list_order_recipients(p_order_id uuid)
returns table(user_id uuid) as $$
  select distinct cu.user_id
    from orders o
    join company_users cu on cu.company_id = o.customer_company_id
   where o.id = p_order_id
  union
  select distinct cu2.user_id
    from order_items oi
    join company_users cu2 on cu2.company_id = oi.vendor_company_id
   where oi.order_id = p_order_id;
$$ language sql stable;

-- RPC: Get company catalog (products visible to company)
create or replace function rpc_company_catalog(p_company uuid)
returns table(
  product_id uuid,
  variant_id uuid,
  sku text,
  name jsonb,
  description jsonb,
  category_id uuid,
  vendor_company_id uuid,
  uom text,
  pack_size int,
  moq int,
  lead_time int,
  active boolean,
  in_stock boolean,
  has_price boolean
) as $$
  select 
    p.id as product_id,
    pv.id as variant_id,
    pv.sku,
    p.name,
    p.description,
    p.category_id,
    p.vendor_company_id,
    p.uom,
    p.pack_size,
    p.moq,
    p.lead_time,
    p.active,
    coalesce(inv.qty > 0, false) as in_stock,
    exists(
      select 1 
      from secure_effective_prices ep 
      where ep.variant_id = pv.id
        and (ep.customer_id = p_company or ep.scope = 'global')
    ) as has_price
  from products p
  join product_variants pv on pv.product_id = p.id
  left join inventory inv on inv.variant_id = pv.id
  where p.active = true
    and pv.active = true
  order by p.created_at desc;
$$ language sql stable security definer;

grant execute on function rpc_company_catalog(uuid) to authenticated, service_role;

-- RPC: Resolve price (wrapper for rpc_effective_price for backwards compatibility)
create or replace function rpc_resolve_price(p_company uuid, p_variant uuid, p_qty numeric)
returns table(unit_price numeric, currency text, price_list_scope price_list_scope, vendor_id uuid) as $$
  select * from rpc_effective_price(p_company, p_variant, p_qty);
$$ language sql stable;

grant execute on function rpc_resolve_price(uuid, uuid, numeric) to authenticated, service_role;
