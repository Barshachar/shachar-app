set search_path = public, auth;

-- Replace legacy effective price artifacts with contract-aware primitives
drop materialized view if exists public.mv_effective_prices;
drop view if exists public.secure_effective_prices;
drop function if exists public.rpc_effective_price(uuid, uuid, numeric);

-- Promote prices table to price_list_items while keeping idempotency
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM information_schema.tables
     WHERE table_schema = 'public'
       AND table_name = 'prices'
  ) AND NOT EXISTS (
    SELECT 1
      FROM information_schema.tables
     WHERE table_schema = 'public'
       AND table_name = 'price_list_items'
  ) THEN
    ALTER TABLE public.prices RENAME TO price_list_items;
  END IF;
END$$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM pg_class
     WHERE relkind IN ('i', 'I')
       AND relnamespace = 'public'::regnamespace
       AND relname = 'prices_unique_idx'
  ) THEN
    ALTER INDEX public.prices_unique_idx RENAME TO price_list_items_unique_idx;
  END IF;
END$$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM pg_trigger
     WHERE tgrelid = 'public.price_list_items'::regclass
       AND tgname = 'prices_refresh_mv'
  ) THEN
    ALTER TABLE public.price_list_items RENAME TRIGGER prices_refresh_mv TO price_list_items_refresh_mv;
  END IF;
END$$;

-- Pricing metadata extensions
alter table public.price_lists
  add column if not exists vat_included boolean not null default false;

alter table public.price_lists
  add column if not exists is_active boolean not null default true;

alter table public.price_list_items
  add column if not exists vat_included boolean not null default false;

alter table public.price_list_items
  alter column min_qty type numeric(14,3)
  using min_qty::numeric(14,3);

alter table public.price_list_items
  alter column unit_price type numeric(14,4)
  using unit_price::numeric(14,4);

create index if not exists price_list_items_variant_qty_idx
  on public.price_list_items (variant_id, min_qty);

-- New collaborative pricing structures
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contract_status') THEN
    CREATE TYPE contract_status AS ENUM ('draft','active','suspended','expired');
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'catalog_visibility_scope') THEN
    CREATE TYPE catalog_visibility_scope AS ENUM ('global','customer');
  END IF;
END$$;

create table if not exists public.contracts (
  id uuid primary key default uuid_generate_v4(),
  vendor_company_id uuid not null references public.companies(id) on delete cascade,
  customer_company_id uuid not null references public.companies(id) on delete cascade,
  price_list_id uuid null references public.price_lists(id) on delete set null,
  code text not null default 'default',
  name text,
  status contract_status not null default 'draft',
  valid_from date not null default current_date,
  valid_to date,
  vat_included boolean not null default false,
  currency text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contracts_vendor_customer_code_key unique (vendor_company_id, customer_company_id, code),
  constraint contracts_valid_range_chk check (valid_to is null or valid_to >= valid_from)
);

create table if not exists public.contract_prices (
  id uuid primary key default uuid_generate_v4(),
  contract_id uuid not null references public.contracts(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id) on delete cascade,
  min_qty numeric(14,3) not null default 1,
  unit_price numeric(14,4) not null,
  currency text not null default 'ILS',
  vat_included boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contract_prices_min_qty_positive check (min_qty > 0),
  constraint contract_prices_unique unique (contract_id, variant_id, min_qty)
);

create table if not exists public.catalog_visibility (
  id uuid primary key default uuid_generate_v4(),
  vendor_company_id uuid not null references public.companies(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id) on delete cascade,
  scope catalog_visibility_scope not null default 'global',
  customer_company_id uuid null references public.companies(id) on delete cascade,
  visible boolean not null default true,
  priority int not null default 100,
  valid_from date not null default current_date,
  valid_to date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint catalog_visibility_scope_customer_chk check (
    (scope = 'global' and customer_company_id is null)
    or (scope = 'customer' and customer_company_id is not null)
  ),
  constraint catalog_visibility_valid_range_chk check (valid_to is null or valid_to >= valid_from),
  constraint catalog_visibility_unique unique (
    vendor_company_id,
    variant_id,
    scope,
    coalesce(customer_company_id, '00000000-0000-0000-0000-000000000000'::uuid)
  )
);

create index if not exists contracts_vendor_idx on public.contracts (vendor_company_id, status);
create index if not exists contracts_customer_idx on public.contracts (customer_company_id, status);
create index if not exists contracts_validity_idx on public.contracts (valid_from, valid_to);

create index if not exists contract_prices_contract_idx on public.contract_prices (contract_id);
create index if not exists contract_prices_variant_idx on public.contract_prices (variant_id, min_qty);

create index if not exists catalog_visibility_company_idx on public.catalog_visibility (customer_company_id, variant_id);
create index if not exists catalog_visibility_vendor_idx on public.catalog_visibility (vendor_company_id, priority);
create index if not exists catalog_visibility_variant_idx on public.catalog_visibility (variant_id);

-- Harden row level security for pricing and catalog artefacts
alter table public.price_list_items enable row level security;

DROP POLICY IF EXISTS prices_admin_all ON public.price_list_items;
DROP POLICY IF EXISTS price_list_items_admin_all ON public.price_list_items;
create policy price_list_items_admin_all
  on public.price_list_items
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

DROP POLICY IF EXISTS prices_vendor_rw ON public.price_list_items;
DROP POLICY IF EXISTS price_list_items_vendor_rw ON public.price_list_items;
create policy price_list_items_vendor_rw
  on public.price_list_items
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.price_lists pl
       where pl.id = public.price_list_items.price_list_id
         and pl.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.price_lists pl
       where pl.id = public.price_list_items.price_list_id
         and pl.vendor_company_id = auth_company_id()
    )
  );

DROP POLICY IF EXISTS prices_customer_read ON public.price_list_items;
DROP POLICY IF EXISTS price_list_items_customer_read ON public.price_list_items;
create policy price_list_items_customer_read
  on public.price_list_items
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from public.price_lists pl
       where pl.id = public.price_list_items.price_list_id
         and pl.is_active
         and (
           pl.scope = 'global'
           or pl.target_id = auth_company_id()
         )
    )
  );

alter table public.contracts enable row level security;

DROP POLICY IF EXISTS contracts_admin_all ON public.contracts;
create policy contracts_admin_all
  on public.contracts
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

DROP POLICY IF EXISTS contracts_vendor_rw ON public.contracts;
create policy contracts_vendor_rw
  on public.contracts
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

DROP POLICY IF EXISTS contracts_customer_read ON public.contracts;
create policy contracts_customer_read
  on public.contracts
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

alter table public.contract_prices enable row level security;

DROP POLICY IF EXISTS contract_prices_admin_all ON public.contract_prices;
create policy contract_prices_admin_all
  on public.contract_prices
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

DROP POLICY IF EXISTS contract_prices_vendor_rw ON public.contract_prices;
create policy contract_prices_vendor_rw
  on public.contract_prices
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.contracts c
       where c.id = public.contract_prices.contract_id
         and c.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.contracts c
       where c.id = public.contract_prices.contract_id
         and c.vendor_company_id = auth_company_id()
    )
  );

DROP POLICY IF EXISTS contract_prices_customer_read ON public.contract_prices;
create policy contract_prices_customer_read
  on public.contract_prices
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from public.contracts c
       where c.id = public.contract_prices.contract_id
         and c.customer_company_id = auth_company_id()
    )
  );

alter table public.catalog_visibility enable row level security;

DROP POLICY IF EXISTS catalog_visibility_admin_all ON public.catalog_visibility;
create policy catalog_visibility_admin_all
  on public.catalog_visibility
  for all
  using (auth_role() = 'admin')
  with check (auth_role() = 'admin');

DROP POLICY IF EXISTS catalog_visibility_vendor_rw ON public.catalog_visibility;
create policy catalog_visibility_vendor_rw
  on public.catalog_visibility
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

DROP POLICY IF EXISTS catalog_visibility_customer_read ON public.catalog_visibility;
create policy catalog_visibility_customer_read
  on public.catalog_visibility
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and (
      scope = 'global'
      or (scope = 'customer' and customer_company_id = auth_company_id())
    )
  );

-- Legacy refresh hook becomes a no-op now that pricing resolves dynamically
create or replace function public.refresh_mv_effective_prices()
returns void
language plpgsql
as $$
begin
  -- kept for backwards compatibility with clients referencing the legacy RPC
  null;
end;
$$;

drop view if exists public.v_effective_price;

create view public.v_effective_price
  with (security_invoker = on)
as
select
  'contract_direct'::text as source,
  cp.contract_id,
  c.vendor_company_id,
  c.customer_company_id,
  cp.variant_id,
  cp.min_qty,
  cp.unit_price,
  cp.currency,
  cp.vat_included,
  c.valid_from,
  c.valid_to,
  0 as precedence,
  0 as priority
from public.contract_prices cp
join public.contracts c on c.id = cp.contract_id
where c.status = 'active'

union all
select
  'contract_price_list'::text as source,
  c.id as contract_id,
  c.vendor_company_id,
  c.customer_company_id,
  pli.variant_id,
  pli.min_qty,
  pli.unit_price,
  pl.currency,
  coalesce(pli.vat_included, pl.vat_included) as vat_included,
  greatest(c.valid_from, pl.valid_from::date) as valid_from,
  nullif(least(
    coalesce(c.valid_to, 'infinity'::date),
    coalesce(pl.valid_to::date, 'infinity'::date)
  ), 'infinity'::date) as valid_to,
  1 as precedence,
  pl.priority
from public.contracts c
join public.price_lists pl on pl.id = c.price_list_id
join public.price_list_items pli on pli.price_list_id = pl.id
where c.status = 'active'
  and pl.is_active

union all
select
  'customer_price_list'::text as source,
  null as contract_id,
  pl.vendor_company_id,
  pl.target_id as customer_company_id,
  pli.variant_id,
  pli.min_qty,
  pli.unit_price,
  pl.currency,
  coalesce(pli.vat_included, pl.vat_included) as vat_included,
  pl.valid_from::date as valid_from,
  pl.valid_to::date as valid_to,
  2 as precedence,
  pl.priority
from public.price_lists pl
join public.price_list_items pli on pli.price_list_id = pl.id
where pl.scope = 'customer'
  and pl.is_active

union all
select
  'global_price_list'::text as source,
  null as contract_id,
  pl.vendor_company_id,
  null as customer_company_id,
  pli.variant_id,
  pli.min_qty,
  pli.unit_price,
  pl.currency,
  coalesce(pli.vat_included, pl.vat_included) as vat_included,
  pl.valid_from::date as valid_from,
  pl.valid_to::date as valid_to,
  3 as precedence,
  pl.priority
from public.price_lists pl
join public.price_list_items pli on pli.price_list_id = pl.id
where pl.scope = 'global'
  and pl.is_active;

grant select on public.v_effective_price to authenticated;
grant select on public.v_effective_price to service_role;

-- RPCs for catalog visibility and price resolution
DROP FUNCTION IF EXISTS public.rpc_company_catalog(uuid);
create or replace function public.rpc_company_catalog(p_company uuid)
returns table (
  variant_id uuid,
  product_id uuid,
  vendor_company_id uuid
) as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_auth_company uuid := auth_company_id();
  v_target_company uuid := coalesce(p_company, v_auth_company);
  v_today date := current_date;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role in ('customer_admin','buyer') then
    if v_auth_company is null or v_target_company is distinct from v_auth_company then
      raise exception 'Tenant violation' using errcode = '42501';
    end if;
  elsif v_role in ('vendor_admin','vendor_user','admin') then
    null; -- allowed
  else
    raise exception 'Role % not permitted', v_role using errcode = '28000';
  end if;

  return query
    with relevant as (
      select
        cv.id,
        cv.variant_id,
        cv.vendor_company_id,
        cv.scope,
        cv.customer_company_id,
        cv.visible,
        cv.priority,
        cv.valid_from,
        cv.valid_to,
        cv.updated_at,
        case when cv.scope = 'customer' and cv.customer_company_id = v_target_company then 0 else 1 end as scope_rank
      from public.catalog_visibility cv
      where cv.valid_from <= v_today
        and (cv.valid_to is null or cv.valid_to >= v_today)
        and (
          cv.scope = 'global'
          or (cv.scope = 'customer' and cv.customer_company_id = v_target_company)
        )
        and (
          v_role not in ('vendor_admin','vendor_user')
          or cv.vendor_company_id = v_auth_company
        )
    ), ranked as (
      select r.*, row_number() over (
              partition by r.variant_id
              order by r.scope_rank, r.priority, r.updated_at desc, r.id
            ) as rn
      from relevant r
    )
    select
      pv.id as variant_id,
      pv.product_id,
      pr.vendor_company_id
    from ranked r
    join public.product_variants pv on pv.id = r.variant_id
    join public.products pr on pr.id = pv.product_id
    where r.rn = 1
      and r.visible = true
      and pr.active = true
      and pv.active = true
      and (
        v_role = 'admin'
        or (v_role in ('vendor_admin','vendor_user') and pr.vendor_company_id = v_auth_company)
        or v_role in ('customer_admin','buyer')
      );
end;
$$ language plpgsql
   security definer
   set search_path = public, auth;

grant execute on function public.rpc_company_catalog(uuid) to authenticated;
grant execute on function public.rpc_company_catalog(uuid) to service_role;

DROP FUNCTION IF EXISTS public.rpc_resolve_price(uuid, uuid, numeric, date);
create or replace function public.rpc_resolve_price(
  p_company uuid,
  p_variant uuid,
  p_qty numeric,
  p_at date default null
) returns table (
  price numeric,
  currency text,
  vat_included boolean
) as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_auth_company uuid := auth_company_id();
  v_vendor uuid;
  v_target_company uuid := p_company;
  v_qty numeric;
  v_at date := coalesce(p_at, current_date);
  v_visible boolean;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if p_variant is null then
    raise exception 'Variant is required';
  end if;

  if p_qty is null or p_qty <= 0 then
    raise exception 'Quantity must be positive';
  end if;
  v_qty := p_qty;

  select pr.vendor_company_id
    into v_vendor
    from public.product_variants pv
    join public.products pr on pr.id = pv.product_id
   where pv.id = p_variant;

  if not found then
    raise exception 'Variant % not found', p_variant using errcode = 'P0001';
  end if;

  if v_role in ('customer_admin','buyer') then
    if v_auth_company is null then
      raise exception 'Tenant context missing' using errcode = '42501';
    end if;
    v_target_company := v_auth_company;
  elsif v_role in ('vendor_admin','vendor_user') then
    if v_vendor is distinct from v_auth_company then
      raise exception 'Variant % belongs to a different vendor', p_variant using errcode = '42501';
    end if;
  elsif v_role = 'admin' then
    null;
  else
    raise exception 'Role % not permitted', v_role using errcode = '28000';
  end if;

  if v_role in ('customer_admin','buyer') then
    select exists (
             select 1
               from public.rpc_company_catalog(v_target_company) c
              where c.variant_id = p_variant
           ) into v_visible;

    if not v_visible then
      raise exception 'Variant % is not visible for company %', p_variant, v_target_company using errcode = '42501';
    end if;
  end if;

  return query
    select ranked.unit_price,
           ranked.currency,
           ranked.vat_included
      from (
        select ve.unit_price,
               ve.currency,
               ve.vat_included,
               row_number() over (
                 order by ve.precedence,
                          case when ve.customer_company_id = v_target_company then 0 else 1 end,
                          ve.priority,
                          ve.min_qty desc
               ) as rn
          from public.v_effective_price ve
         where ve.variant_id = p_variant
           and ve.vendor_company_id = v_vendor
           and ve.min_qty <= v_qty
           and (ve.customer_company_id is null or ve.customer_company_id = v_target_company)
           and (ve.valid_from is null or ve.valid_from <= v_at)
           and (ve.valid_to is null or ve.valid_to >= v_at)
      ) ranked
     where ranked.rn = 1;

  if not found then
    raise exception 'No price available for variant % at qty %', p_variant, v_qty using errcode = 'P0002';
  end if;
end;
$$ language plpgsql
   security definer
   set search_path = public, auth;

grant execute on function public.rpc_resolve_price(uuid, uuid, numeric, date) to authenticated;
grant execute on function public.rpc_resolve_price(uuid, uuid, numeric, date) to service_role;

-- Re-wire dependent RPCs to the new pricing stack
DROP FUNCTION IF EXISTS public.rpc_add_line(uuid, uuid, numeric);
create or replace function public.rpc_add_line(p_order_id uuid, p_variant_id uuid, p_qty numeric)
returns uuid as $$
declare
  v_tenant uuid := auth_company_id();
  v_role user_role := auth_role();
  v_order_company uuid;
  v_order_status order_status;
  v_vendor uuid;
  v_uom text;
  v_product_active boolean;
  v_variant_active boolean;
  v_price numeric;
  v_item_id uuid;
begin
  if v_role not in ('customer_admin', 'buyer') then
    raise exception 'Only customer roles may add items';
  end if;

  if p_qty is null or p_qty <= 0 then
    raise exception 'Quantity must be positive';
  end if;

  select customer_company_id, status
    into v_order_company, v_order_status
    from public.orders
   where id = p_order_id;

  if not found then
    raise exception 'Order % not found', p_order_id;
  end if;

  if v_order_company is distinct from v_tenant then
    raise exception 'Tenant mismatch for order %', p_order_id using errcode = '42501';
  end if;

  if v_order_status <> 'draft' then
    raise exception 'Order % is not editable', p_order_id;
  end if;

  select p.vendor_company_id,
         pv.uom,
         p.active,
         pv.active
    into v_vendor, v_uom, v_product_active, v_variant_active
    from public.product_variants pv
    join public.products p on p.id = pv.product_id
   where pv.id = p_variant_id;

  if not found then
    raise exception 'Variant % not found', p_variant_id;
  end if;

  if not v_product_active or not v_variant_active then
    raise exception 'Variant % is inactive', p_variant_id;
  end if;

  perform order_item_customer_guard(p_order_id);

  select price
    into v_price
    from public.rpc_resolve_price(v_tenant, p_variant_id, p_qty, current_date)
   limit 1;

  if v_price is null then
    raise exception 'No price available for variant %', p_variant_id;
  end if;

  select id
    into v_item_id
    from public.order_items
   where order_id = p_order_id
     and variant_id = p_variant_id
   limit 1;

  if v_item_id is null then
    insert into public.order_items(order_id, vendor_company_id, variant_id, qty, uom, unit_price, discount_pct, tax_rate)
    values (p_order_id, v_vendor, p_variant_id, p_qty, v_uom, v_price, 0, 17)
    returning id into v_item_id;
  else
    update public.order_items
       set qty = qty + p_qty,
           unit_price = v_price,
           updated_at = now()
     where id = v_item_id;
  end if;

  return v_item_id;
end;
$$ language plpgsql security definer set search_path = public, auth;

grant execute on function public.rpc_add_line(uuid, uuid, numeric) to authenticated;

DROP FUNCTION IF EXISTS public.rpc_submit_order(uuid);
create or replace function public.rpc_submit_order(p_order_id uuid)
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
    from public.orders
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
      from public.order_items oi
     where oi.order_id = p_order_id
  loop
    select price
      into v_unit_price
      from public.rpc_resolve_price(v_customer, v_record.variant_id, v_record.qty, current_date)
     limit 1;

    if v_unit_price is null then
      raise exception 'Missing price for variant %', v_record.variant_id;
    end if;

    update public.order_items
       set unit_price = v_unit_price,
           tax_rate = 17.00
     where id = v_record.id;
  end loop;

  select coalesce(sum(unit_price * qty * (1 - discount_pct / 100)), 0),
         coalesce(sum((unit_price * qty * (1 - discount_pct / 100)) * (tax_rate / 100)), 0),
         coalesce(sum(line_total), 0)
    into v_subtotal, v_tax, v_total
    from public.order_items
   where order_id = p_order_id;

  update public.orders
     set status = 'placed',
         subtotal = v_subtotal,
         tax_total = v_tax,
         total = v_total,
         updated_at = now()
   where id = p_order_id;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (auth.uid(), 'order_submitted', 'orders', p_order_id, jsonb_build_object('total', v_total));

  return p_order_id;
end;
$$ language plpgsql security definer set search_path = public, auth;

drop function if exists public.rpc_upsert_prices(uuid, jsonb);
create or replace function public.rpc_upsert_prices(p_vendor uuid, p_rows jsonb)
returns int as $$
declare
  v_row jsonb;
  v_count int := 0;
  v_price_list uuid;
  v_scope price_list_scope;
  v_target uuid;
  v_variant uuid;
  v_price numeric;
  v_min_qty numeric;
  v_currency text;
  v_priority int;
  v_valid_from date;
  v_valid_to date;
  v_vat boolean;
begin
  if auth_role() not in ('admin','vendor_admin') then
    raise exception 'Insufficient role';
  end if;

  if auth_role() = 'vendor_admin' and auth_company_id() <> p_vendor then
    raise exception 'Tenant violation' using errcode = '42501';
  end if;

  if p_vendor is null then
    raise exception 'Vendor is required';
  end if;

  for v_row in select * from jsonb_array_elements(p_rows)
  loop
    v_scope := coalesce((v_row->>'scope')::price_list_scope, 'global');
    v_target := (v_row->>'customer_id')::uuid;
    v_variant := (v_row->>'variant_id')::uuid;
    v_price := (v_row->>'unit_price')::numeric;
    v_min_qty := greatest(coalesce((v_row->>'min_qty')::numeric, 1), 1);
    v_currency := coalesce(v_row->>'currency', 'ILS');
    v_priority := coalesce((v_row->>'priority')::int, 100);
    v_valid_from := coalesce((v_row->>'valid_from')::date, current_date);
    v_valid_to := (v_row->>'valid_to')::date;
    v_vat := coalesce((v_row->>'vat_included')::boolean, false);

    if v_variant is null or v_price is null then
      raise exception 'Variant and unit_price are required in payload row %', v_row;
    end if;

    if v_scope = 'customer' and v_target is null then
      raise exception 'customer_id is required when scope=customer';
    end if;

    select id into v_price_list
      from public.price_lists
     where vendor_company_id = p_vendor
       and scope = v_scope
       and coalesce(target_id, '00000000-0000-0000-0000-000000000000'::uuid) = coalesce(v_target, '00000000-0000-0000-0000-000000000000'::uuid)
     limit 1;

    if v_price_list is null then
      insert into public.price_lists(
        vendor_company_id,
        scope,
        target_id,
        name,
        priority,
        currency,
        valid_from,
        valid_to,
        vat_included,
        is_active
      )
      values (
        p_vendor,
        v_scope,
        v_target,
        concat('Imported ', now()),
        v_priority,
        v_currency,
        v_valid_from::timestamptz,
        case when v_valid_to is null then null else v_valid_to::timestamptz end,
        v_vat,
        true
      )
      returning id into v_price_list;
    else
      update public.price_lists
         set priority = v_priority,
             currency = v_currency,
             valid_from = v_valid_from::timestamptz,
             valid_to = case when v_valid_to is null then null else v_valid_to::timestamptz end,
             vat_included = v_vat,
             is_active = true,
             updated_at = now()
       where id = v_price_list;
    end if;

    insert into public.price_list_items(price_list_id, variant_id, min_qty, unit_price, vat_included)
    values (v_price_list, v_variant, v_min_qty, v_price, v_vat)
    on conflict (price_list_id, variant_id, min_qty)
    do update set
      unit_price = excluded.unit_price,
      vat_included = excluded.vat_included;

    v_count := v_count + 1;
  end loop;

  perform public.refresh_mv_effective_prices();
  return v_count;
end;
$$ language plpgsql security definer set search_path = public, auth;

grant execute on function public.rpc_upsert_prices(uuid, jsonb) to authenticated;
grant execute on function public.rpc_upsert_prices(uuid, jsonb) to service_role;

-- Backward-compatible wrapper to support existing clients until they switch to rpc_resolve_price
create or replace function public.rpc_effective_price(p_customer uuid, p_variant uuid, p_qty numeric)
returns table (
  unit_price numeric,
  currency text,
  price_list_scope price_list_scope,
  vendor_id uuid
) as $$
  select result.unit_price,
         result.currency,
         result.scope,
         result.vendor_id
    from (
      select ve.unit_price,
             ve.currency,
             case when ve.customer_company_id is null then 'global'::price_list_scope else 'customer'::price_list_scope end as scope,
             ve.vendor_company_id as vendor_id,
             row_number() over (
               order by ve.precedence,
                        case when ve.customer_company_id = p_customer then 0 else 1 end,
                        ve.priority,
                        ve.min_qty desc
             ) as rn
        from public.v_effective_price ve
       where ve.variant_id = p_variant
         and ve.min_qty <= coalesce(p_qty, 1)
         and (ve.customer_company_id is null or ve.customer_company_id = p_customer)
         and (ve.valid_from is null or ve.valid_from <= current_date)
         and (ve.valid_to is null or ve.valid_to >= current_date)
    ) result
   where result.rn = 1;
$$ language sql
   stable
   set search_path = public, auth;

grant execute on function public.rpc_effective_price(uuid, uuid, numeric) to authenticated;
grant execute on function public.rpc_effective_price(uuid, uuid, numeric) to service_role;
