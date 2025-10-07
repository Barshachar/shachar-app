set search_path = public, auth;

create index if not exists product_variants_sku_trgm_idx
  on public.product_variants using gin (sku gin_trgm_ops);

create index if not exists product_variants_barcode_trgm_idx
  on public.product_variants using gin (barcode gin_trgm_ops);

create index if not exists products_name_en_trgm_idx
  on public.products using gin ((name ->> 'en') gin_trgm_ops);

drop function if exists public.rpc_find_by_code(text);
drop function if exists public.rpc_add_line(uuid, uuid, numeric);

drop view if exists public.v_catalog_search;
create view public.v_catalog_search
  with (security_invoker = on)
as
select
  p.id as product_id,
  pv.id as variant_id,
  p.vendor_company_id,
  pv.sku,
  pv.barcode,
  p.name ->> 'he' as name_he,
  p.name ->> 'en' as name_en,
  (p.active and pv.active) as active,
  coalesce(inv.total_qty, 0::numeric) as inventory_qty,
  pv.uom as unit_uom
from public.products p
join public.product_variants pv on pv.product_id = p.id
left join (
  select variant_id, sum(qty) as total_qty
  from public.inventory
  group by variant_id
) inv on inv.variant_id = pv.id;

create or replace function public.rpc_find_by_code(p_code text)
returns table (
  product_id uuid,
  variant_id uuid,
  vendor_company_id uuid,
  sku text,
  barcode text,
  name_he text,
  name_en text,
  active boolean,
  inventory_qty numeric,
  unit_uom text
) as $$
  select v.product_id,
         v.variant_id,
         v.vendor_company_id,
         v.sku,
         v.barcode,
         v.name_he,
         v.name_en,
         v.active,
         v.inventory_qty,
         v.unit_uom
    from public.v_catalog_search v
    join public.products p on p.id = v.product_id
    join public.product_variants pv on pv.id = v.variant_id
   where trim(coalesce(p_code, '')) <> ''
     and (
       lower(pv.sku) = lower(p_code)
       or lower(p.sku) = lower(p_code)
       or (pv.barcode is not null and pv.barcode = p_code)
       or pv.sku ilike '%' || p_code || '%'
       or (pv.barcode is not null and pv.barcode ilike '%' || p_code || '%')
     )
   order by case
              when lower(pv.sku) = lower(p_code) then 0
              when lower(p.sku) = lower(p_code) then 1
              when pv.barcode = p_code then 2
              else 3
            end,
            v.sku
   limit 20;
$$ language sql
   stable
   set search_path = public, auth;

grant execute on function public.rpc_find_by_code(text) to authenticated;

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

  select unit_price
    into v_price
    from public.rpc_effective_price(v_tenant, p_variant_id, p_qty)
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
    insert into public.order_items(order_id, vendor_company_id, variant_id, qty, uom, unit_price)
    values (p_order_id, v_vendor, p_variant_id, p_qty, v_uom, v_price)
    returning id into v_item_id;
  else
    update public.order_items
       set qty = p_qty,
           unit_price = v_price
     where id = v_item_id
     returning id into v_item_id;
  end if;

  return v_item_id;
end;
$$ language plpgsql
   set search_path = public, auth;

grant execute on function public.rpc_add_line(uuid, uuid, numeric) to authenticated;
