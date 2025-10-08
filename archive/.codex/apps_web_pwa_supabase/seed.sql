insert into public.categories (name, slug, image_url)
values
  ('צנרת ואביזרי מים', 'plumbing', '/categories/plumbing.png'),
  ('כלי עבודה לאינסטלטורים', 'tools', '/categories/tools.png'),
  ('כלים סניטריים', 'fixtures', '/categories/fixtures.png')
on conflict (slug) do update set name = excluded.name, image_url = excluded.image_url;

insert into public.vendors (name, slug, logo_url)
values
  ('א.שחר', 'ashachar', '/brands/ashachar.png'),
  ('AquaFlow', 'aquaFlow', '/brands/aquaFlow.png'),
  ('MegaPipe', 'megaPipe', '/brands/megaPipe.png')
on conflict (slug) do update set name = excluded.name, logo_url = excluded.logo_url;

-- Example products and variants
with upsert_product as (
  insert into public.products (name, slug, sku, brand, vendor_slug, category_slug, primary_image_url, description_html)
  values
    ('סט ברז נשלף מקצועי', 'pullout-faucet-pro', 'FCT-001', 'AquaFlow', 'aquaFlow', 'fixtures', '/placeholders/p0.png', '<p>ברז מטבח נשלף גוף פלדת על חלד, אחריות יצרן מלאה.</p>'),
    ('משאבת לחץ מים 1HP', 'booster-pump-1hp', 'PMP-445', 'MegaPipe', 'megaPipe', 'plumbing', '/placeholders/p0.png', '<p>משאבת לחץ מים עם הנעה שקטה וחיישן זרימה.</p>'),
    ('ערכת אטמים מקצועית 120 חלקים', 'o-ring-kit-pro-120', 'KIT-120', 'א.שחר', 'ashachar', 'tools', '/placeholders/p0.png', '<p>אטמים במידות שונות, נרתיק איכותי לשטח.</p>')
  on conflict (slug) do update set name = excluded.name, sku = excluded.sku, brand = excluded.brand, vendor_slug = excluded.vendor_slug, category_slug = excluded.category_slug, primary_image_url = excluded.primary_image_url, description_html = excluded.description_html
  returning id, slug
)
select 1;

-- Clean variants to avoid duplicates
delete from public.product_variants where product_id in (select id from public.products where slug in ('pullout-faucet-pro','booster-pump-1hp','o-ring-kit-pro-120'));

delete from public.variant_prices where variant_id not in (select id from public.product_variants);

insert into public.product_variants (product_id, name, sku, price_cents, currency)
select p.id,
       case p.slug
         when 'pullout-faucet-pro' then 'סטנדרטי'
         when 'booster-pump-1hp' then '220V'
         else 'מקצועי'
       end as name,
       case p.slug
         when 'pullout-faucet-pro' then 'FCT-001-ST'
         when 'booster-pump-1hp' then 'PMP-445-220'
         else 'KIT-120-PRO'
       end as sku,
       case p.slug
         when 'pullout-faucet-pro' then 129900
         when 'booster-pump-1hp' then 185000
         else 45900
       end as price_cents,
       'ILS'
from public.products p
where p.slug in ('pullout-faucet-pro','booster-pump-1hp','o-ring-kit-pro-120')
returning id, product_id;

insert into public.variant_prices (variant_id, price_group, price_cents)
select pv.id,
       price.price_group,
       price.price_cents
from public.product_variants pv
join public.products p on p.id = pv.product_id
join lateral (
  values
    ('pullout-faucet-pro', 'installer', 109900),
    ('pullout-faucet-pro', 'wholesale', 99900),
    ('booster-pump-1hp', 'installer', 169000),
    ('o-ring-kit-pro-120', 'installer', 39900)
) as price(slug, price_group, price_cents) on price.slug = p.slug
on conflict (variant_id, price_group) do update set price_cents = excluded.price_cents;
