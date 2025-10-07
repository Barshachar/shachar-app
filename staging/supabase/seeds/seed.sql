-- Seed data for א.שחר Marketplace
truncate table audit_log cascade;
truncate table notifications cascade;
truncate table attachments cascade;
truncate table shipments cascade;
truncate table order_items cascade;
truncate table orders cascade;
truncate table prices cascade;
truncate table price_lists cascade;
truncate table inventory cascade;
truncate table product_variants cascade;
truncate table products cascade;
truncate table attributes cascade;
truncate table categories cascade;
truncate table company_users cascade;
truncate table companies cascade;
truncate table auth.users cascade;

-- Companies
insert into companies (id, type, status, name, locale, currency, timezone)
values
  ('10000000-0000-0000-0000-000000000000', 'admin', 'active', 'Ashachar HQ', 'he', 'ILS', 'Asia/Jerusalem'),
  ('20000000-0000-0000-0000-000000000000', 'vendor', 'active', 'Herbs Supplier', 'he', 'ILS', 'Asia/Jerusalem'),
  ('20000000-0000-0000-0000-000000000001', 'vendor', 'active', 'Packaging Depot', 'he', 'ILS', 'Asia/Jerusalem'),
  ('20000000-0000-0000-0000-000000000002', 'vendor', 'pending', 'Fresh Dairy', 'he', 'ILS', 'Asia/Jerusalem'),
  ('30000000-0000-0000-0000-000000000000', 'customer', 'active', 'SuperMart Chain', 'he', 'ILS', 'Asia/Jerusalem'),
  ('30000000-0000-0000-0000-000000000001', 'customer', 'active', 'Cafe Delights', 'he', 'ILS', 'Asia/Jerusalem'),
  ('30000000-0000-0000-0000-000000000002', 'customer', 'active', 'Hotel Plaza', 'he', 'ILS', 'Asia/Jerusalem');

-- Users
insert into auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, raw_app_meta_data, created_at)
values
  ('11111111-1111-1111-1111-111111111111', 'admin@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Admin Demo","locale":"he"}', '{"role":"admin","company_id":"10000000-0000-0000-0000-000000000000","company_type":"admin"}', now()),
  ('22222222-2222-2222-2222-222222222222', 'vendor1@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Vendor One","locale":"he"}', '{"role":"vendor_admin","company_id":"20000000-0000-0000-0000-000000000000","company_type":"vendor"}', now()),
  ('22222222-2222-2222-2222-222222222223', 'vendor2@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Vendor Two","locale":"he"}', '{"role":"vendor_admin","company_id":"20000000-0000-0000-0000-000000000001","company_type":"vendor"}', now()),
  ('33333333-3333-3333-3333-333333333333', 'buyer1@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Buyer One","locale":"he"}', '{"role":"buyer","company_id":"30000000-0000-0000-0000-000000000000","company_type":"customer"}', now()),
  ('33333333-3333-3333-3333-333333333334', 'buyer2@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Buyer Two","locale":"he"}', '{"role":"customer_admin","company_id":"30000000-0000-0000-0000-000000000001","company_type":"customer"}', now()),
  ('33333333-3333-3333-3333-333333333335', 'buyer3@demo.local', crypt('Demo123!', gen_salt('bf')), now(), '{"full_name":"Buyer Three","locale":"en"}', '{"role":"customer_admin","company_id":"30000000-0000-0000-0000-000000000002","company_type":"customer"}', now());

-- Company user mapping
insert into company_users (company_id, user_id, role)
values
  ('10000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111', 'admin'),
  ('20000000-0000-0000-0000-000000000000', '22222222-2222-2222-2222-222222222222', 'vendor_admin'),
  ('20000000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222223', 'vendor_admin'),
  ('30000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333', 'buyer'),
  ('30000000-0000-0000-0000-000000000001', '33333333-3333-3333-3333-333333333334', 'customer_admin'),
  ('30000000-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333335', 'customer_admin');

-- Categories
insert into categories (id, name, sort_order)
values
  ('40000000-0000-0000-0000-000000000000', '{"he":"תבלינים","en":"Herbs"}', 1),
  ('40000000-0000-0000-0000-000000000001', '{"he":"אריזות","en":"Packaging"}', 2),
  ('40000000-0000-0000-0000-000000000002', '{"he":"מוצרי חלב","en":"Dairy"}', 3);

-- Attributes
insert into attributes (id, code, name, type)
values
  ('50000000-0000-0000-0000-000000000000', 'size', '{"he":"גודל","en":"Size"}', 'text'),
  ('50000000-0000-0000-0000-000000000001', 'flavor', '{"he":"טעם","en":"Flavor"}', 'text'),
  ('50000000-0000-0000-0000-000000000002', 'pack', '{"he":"יחידות","en":"Pack"}', 'number');

-- Products & Variants (sample 6 products, each with variants)
insert into products (id, vendor_company_id, category_id, sku, name, description, uom, pack_size, moq, lead_time, active)
values
  ('60000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000000', 'HERB-001', '{"he":"עלי בזיליקום","en":"Basil Leaves"}', '{"he":"עלים טריים לבישול","en":"Fresh leaves"}', 'KG', 1, 1, 2, true),
  ('60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000000', 'HERB-002', '{"he":"עלי נענע","en":"Mint Leaves"}', '{"he":"נענע טרייה","en":"Fresh mint"}', 'KG', 1, 1, 1, true),
  ('60000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'PACK-001', '{"he":"קופסת קרטון 5קג","en":"Carton Box 5kg"}', '{"he":"למשלוחים","en":"For shipments"}', 'EA', 10, 5, 3, true),
  ('60000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'PACK-002', '{"he":"גליל ניילון","en":"Stretch Wrap"}', '{"he":"לאריזה","en":"Packaging"}', 'EA', 24, 1, 2, true),
  ('60000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 'DAIRY-001', '{"he":"חלב 3%","en":"Milk 3%"}', '{"he":"בקבוק 1 ליטר","en":"1L bottle"}', 'EA', 12, 24, 2, true),
  ('60000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 'DAIRY-002', '{"he":"גבינה קשה","en":"Hard Cheese"}', '{"he":"גלילים","en":"Blocks"}', 'KG', 5, 5, 5, false);

insert into product_variants (id, product_id, attributes_json, sku, barcode, uom, active)
values
  ('70000000-0000-0000-0000-000000000000', '60000000-0000-0000-0000-000000000000', '{"size":"1kg","flavor":"Classic"}', 'HERB-001-A', '1111111111111', 'KG', true),
  ('70000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '{"size":"1kg","flavor":"Mint"}', 'HERB-002-A', '1111111111112', 'KG', true),
  ('70000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000002', '{"pack":"10"}', 'PACK-001-A', '2222222222222', 'EA', true),
  ('70000000-0000-0000-0000-000000000003', '60000000-0000-0000-0000-000000000003', '{"pack":"24"}', 'PACK-002-A', '2222222222223', 'EA', true),
  ('70000000-0000-0000-0000-000000000004', '60000000-0000-0000-0000-000000000004', '{"size":"1L"}', 'DAIRY-001-A', '3333333333333', 'EA', true),
  ('70000000-0000-0000-0000-000000000005', '60000000-0000-0000-0000-000000000005', '{"size":"5kg"}', 'DAIRY-002-A', '3333333333334', 'KG', true);

insert into inventory (variant_id, qty, low_stock_threshold, updated_at)
values
  ('70000000-0000-0000-0000-000000000000', 120, 20, now()),
  ('70000000-0000-0000-0000-000000000001', 80, 15, now()),
  ('70000000-0000-0000-0000-000000000002', 300, 50, now()),
  ('70000000-0000-0000-0000-000000000003', 200, 30, now()),
  ('70000000-0000-0000-0000-000000000004', 500, 100, now()),
  ('70000000-0000-0000-0000-000000000005', 40, 10, now());

-- Price lists & prices
insert into price_lists (id, vendor_company_id, scope, target_id, name, valid_from, priority, currency)
values
  ('80000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000000', 'global', null, 'Herbs Global', now(), 100, 'ILS'),
  ('80000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000000', 'customer', '30000000-0000-0000-0000-000000000000', 'SuperMart Herbs', now(), 10, 'ILS'),
  ('80000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'global', null, 'Packaging Global', now(), 100, 'ILS'),
  ('80000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', 'customer', '30000000-0000-0000-0000-000000000001', 'Cafe Packaging', now(), 50, 'ILS'),
  ('80000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000002', 'global', null, 'Dairy Global', now(), 100, 'ILS');

insert into prices (id, price_list_id, variant_id, min_qty, unit_price)
values
  ('90000000-0000-0000-0000-000000000000', '80000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000000', 1, 32.00),
  ('90000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000001', 1, 22.50),
  ('90000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000000', 10, 28.00),
  ('90000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', 10, 20.00),
  ('90000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-000000000002', 1, 5.50),
  ('90000000-0000-0000-0000-000000000005', '80000000-0000-0000-0000-000000000002', '70000000-0000-0000-0000-000000000003', 1, 8.90),
  ('90000000-0000-0000-0000-000000000006', '80000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-000000000002', 20, 5.00),
  ('90000000-0000-0000-0000-000000000007', '80000000-0000-0000-0000-000000000003', '70000000-0000-0000-0000-000000000003', 20, 8.40),
  ('90000000-0000-0000-0000-000000000008', '80000000-0000-0000-0000-000000000004', '70000000-0000-0000-0000-000000000004', 1, 4.20),
  ('90000000-0000-0000-0000-000000000009', '80000000-0000-0000-0000-000000000004', '70000000-0000-0000-0000-000000000005', 1, 44.00);

-- Refresh mv
select refresh_mv_effective_prices();

-- Sample order for SuperMart splitted vendors
insert into orders (id, customer_company_id, created_by, status, currency, created_at)
values ('A0000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333', 'placed', 'ILS', now());

insert into order_items (id, order_id, vendor_company_id, variant_id, qty, uom, unit_price, discount_pct, tax_rate)
values
  ('B0000000-0000-0000-0000-000000000000', 'A0000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000000', 12, 'KG', 28.00, 0, 17.00),
  ('B0000000-0000-0000-0000-000000000001', 'A0000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000002', 30, 'EA', 5.00, 0, 17.00);

update orders set
  subtotal = (28.00 * 12) + (5.00 * 30),
  tax_total = ((28.00 * 12) + (5.00 * 30)) * 0.17,
  total = subtotal + tax_total
where id = 'A0000000-0000-0000-0000-000000000000';

insert into shipments (id, order_id, vendor_company_id, status, tracking, partial_flag)
values
  ('C0000000-0000-0000-0000-000000000000', 'A0000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000000', 'in_transit', 'SM-TRACK-1001', false),
  ('C0000000-0000-0000-0000-000000000001', 'A0000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000001', 'ready', 'PK-TRACK-2033', true);

insert into notifications (id, user_id, title, body, data)
values
  ('D0000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333', 'Order placed', 'Your order ORD-A0000000 has been placed', '{"order_id":"A0000000-0000-0000-0000-000000000000"}');

insert into audit_log (id, actor_user_id, action, table_name, row_id, metadata)
values
  ('E0000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333', 'order_submitted', 'orders', 'A0000000-0000-0000-0000-000000000000', '{"total":3456.00}');
