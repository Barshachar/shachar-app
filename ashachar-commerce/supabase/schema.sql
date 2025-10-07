-- Enable UUID generation
create extension if not exists "pgcrypto";

-- Categories
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  image_url text,
  parent_id uuid references public.categories(id) on delete set null
);

-- Vendors
create table if not exists public.vendors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  logo_url text
);

-- Products
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  sku text,
  brand text,
  vendor_slug text not null references public.vendors(slug),
  category_slug text not null references public.categories(slug),
  primary_image_url text,
  description_html text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_category_slug_idx on public.products(category_slug);
create index if not exists products_vendor_slug_idx on public.products(vendor_slug);

-- Product Variants
create table if not exists public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  name text not null,
  sku text,
  price_cents integer not null,
  currency text not null default 'ILS',
  barcode text
);

create index if not exists product_variants_product_id_idx on public.product_variants(product_id);

-- Variant Prices (B2B tiers)
create table if not exists public.variant_prices (
  variant_id uuid not null references public.product_variants(id) on delete cascade,
  price_group text not null,
  price_cents integer not null,
  primary key (variant_id, price_group)
);

-- Carts
create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique,
  customer_id uuid
);

-- Cart items
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id),
  qty integer not null check (qty > 0)
);

create index if not exists cart_items_cart_idx on public.cart_items(cart_id);
create index if not exists cart_items_variant_idx on public.cart_items(variant_id);

-- Orders
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null,
  customer_id uuid,
  total_cents integer not null,
  status text not null check (status in ('pending', 'paid', 'failed')),
  payment_ref text,
  created_at timestamptz not null default now()
);

create index if not exists orders_session_idx on public.orders(session_id);

-- Order items
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id),
  product_name text not null,
  variant_name text not null,
  unit_price_cents integer not null,
  qty integer not null,
  total_cents integer not null
);

-- Helper view to expose cart items with related data
create or replace view public.cart_items_view as
select
  ci.id,
  ci.cart_id,
  ci.variant_id,
  ci.qty,
  jsonb_build_object(
    'id', pv.id,
    'name', pv.name,
    'sku', pv.sku,
    'price_cents', pv.price_cents,
    'currency', pv.currency,
    'barcode', pv.barcode,
    'variant_prices', coalesce(
      jsonb_agg(distinct jsonb_build_object(
        'price_group', vp.price_group,
        'price_cents', vp.price_cents
      )) filter (where vp.price_group is not null),
      '[]'::jsonb
    )
  ) as variant,
  jsonb_build_object(
    'id', p.id,
    'name', p.name,
    'primary_image_url', p.primary_image_url,
    'vendor_slug', p.vendor_slug
  ) as product
from public.cart_items ci
join public.product_variants pv on pv.id = ci.variant_id
join public.products p on p.id = pv.product_id
left join public.variant_prices vp on vp.variant_id = pv.id
group by ci.id, ci.cart_id, ci.variant_id, ci.qty, pv.id, p.id;

-- RPC to aggregate cart totals
create or replace function public.cart_with_prices(p_cart_id uuid)
returns table (
  item_id uuid,
  variant_id uuid,
  qty integer,
  price_cents integer,
  total_cents integer
) security definer set search_path = public as $$
  select
    ci.id as item_id,
    ci.variant_id,
    ci.qty,
    pv.price_cents,
    pv.price_cents * ci.qty as total_cents
  from public.cart_items ci
  join public.product_variants pv on pv.id = ci.variant_id
  where ci.cart_id = p_cart_id;
$$ language sql;

grant execute on function public.cart_with_prices(uuid) to anon, authenticated;

-- Optional helper RPC used by API to add items
create or replace function public.add_to_cart(p_cart_id uuid, p_variant_id uuid, p_qty integer default 1)
returns void security definer set search_path = public as $$
begin
  if exists (select 1 from public.cart_items where cart_id = p_cart_id and variant_id = p_variant_id) then
    update public.cart_items
    set qty = qty + p_qty
    where cart_id = p_cart_id and variant_id = p_variant_id;
  else
    insert into public.cart_items(cart_id, variant_id, qty)
    values (p_cart_id, p_variant_id, greatest(1, p_qty));
  end if;
end;
$$ language plpgsql;

grant execute on function public.add_to_cart(uuid, uuid, integer) to service_role;

