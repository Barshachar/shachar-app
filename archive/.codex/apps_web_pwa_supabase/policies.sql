-- Enable RLS
alter table public.categories enable row level security;
alter table public.vendors enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.variant_prices enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Catalog read policies
create policy if not exists "Public read categories" on public.categories for select using (true);
create policy if not exists "Public read vendors" on public.vendors for select using (true);
create policy if not exists "Public read products" on public.products for select using (is_active);
create policy if not exists "Public read product_variants" on public.product_variants for select using (true);
create policy if not exists "Public read variant_prices" on public.variant_prices for select using (true);

-- PoC policies for cart and orders (to be hardened)
create policy if not exists "Session carts read/write" on public.carts for all using (true) with check (true);
create policy if not exists "Cart items read/write" on public.cart_items for all using (true) with check (true);
create policy if not exists "Orders read/write" on public.orders for all using (true) with check (true);
create policy if not exists "Order items read/write" on public.order_items for all using (true) with check (true);

-- Grant execution to RPCs
grant usage on schema public to anon, authenticated, service_role;
