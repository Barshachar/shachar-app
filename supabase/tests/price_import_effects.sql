\set ON_ERROR_STOP on

-- Generate fixture ids
select
  gen_random_uuid() as vendor1,
  gen_random_uuid() as vendor2,
  gen_random_uuid() as variant1,
  gen_random_uuid() as price_list1,
  gen_random_uuid() as price_list2
\gset

-- Vendors
insert into companies (id, type, status, name, locale, currency, timezone)
values
  (:'vendor1', 'vendor', 'active', 'Price Import Vendor 1', 'he', 'ILS', 'Asia/Jerusalem'),
  (:'vendor2', 'vendor', 'active', 'Price Import Vendor 2', 'he', 'ILS', 'Asia/Jerusalem');

-- Minimal product + variant owned by vendor1
insert into products (id, vendor_company_id, category_id, sku, name, uom)
values (:'variant1', :'vendor1', null, concat('price-import-sku-', :'vendor1'), '{"he":"prod","en":"prod"}', 'EA');

insert into product_variants (id, product_id, attributes_json, sku, uom, active)
values (:'variant1', :'variant1', '{}'::jsonb, concat('price-import-sku-var-', :'variant1'), 'EA', true);

-- Price lists
insert into price_lists (id, vendor_company_id, scope, target_id, name, currency)
values
  (:'price_list1', :'vendor1', 'global', null, 'Price Import PL V1', 'ILS'),
  (:'price_list2', :'vendor2', 'global', null, 'Price Import PL V2', 'ILS');

-- Prices per vendor
insert into prices (price_list_id, variant_id, min_qty, unit_price)
values
  (:'price_list1', :'variant1', 1, 1000),
  (:'price_list2', :'variant1', 1, 2000);

refresh materialized view mv_effective_prices;

create temporary table before_prices as
select vendor_id, unit_price
from mv_effective_prices
where variant_id = :'variant1';

-- Update vendor1 price only
update prices
   set unit_price = 12345
 where price_list_id = :'price_list1'
   and variant_id = :'variant1'
   and min_qty = 1;

refresh materialized view mv_effective_prices;

create temporary table after_prices as
select vendor_id, unit_price
from mv_effective_prices
where variant_id = :'variant1';

do $$
declare
  before_v1 numeric;
  after_v1 numeric;
  before_v2 numeric;
  after_v2 numeric;
begin
  select unit_price
    into before_v1
    from before_prices
   where vendor_id = (select id from companies where name = 'Price Import Vendor 1' limit 1);

  select unit_price
    into before_v2
    from before_prices
   where vendor_id = (select id from companies where name = 'Price Import Vendor 2' limit 1);

  select unit_price
    into after_v1
    from after_prices
   where vendor_id = (select id from companies where name = 'Price Import Vendor 1' limit 1);

  select unit_price
    into after_v2
    from after_prices
   where vendor_id = (select id from companies where name = 'Price Import Vendor 2' limit 1);

  if after_v1 <> 12345 then
    raise exception 'expected vendor1 price 12345, got %', after_v1;
  end if;
  if before_v2 <> after_v2 then
    raise exception 'vendor2 price changed unexpectedly from % to %', before_v2, after_v2;
  end if;
end$$;
