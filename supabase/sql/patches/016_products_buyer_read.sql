set search_path = public, auth;

drop policy if exists products_customer_read on public.products;
create policy products_customer_read
  on public.products
  for select to authenticated
  using (
    auth_role() = ANY (ARRAY['customer_admin'::user_role, 'buyer'::user_role])
    and active = true
  );

drop policy if exists variants_customer_read on public.product_variants;
create policy variants_customer_read
  on public.product_variants
  for select to authenticated
  using (
    auth_role() = ANY (ARRAY['customer_admin'::user_role, 'buyer'::user_role])
    and active = true
  );

drop policy if exists product_variants_customer_read on public.product_variants;
create policy product_variants_customer_read
  on public.product_variants
  for select to authenticated
  using (
    auth_role() = ANY (ARRAY['customer_admin'::user_role, 'buyer'::user_role])
    and active = true
  );
