set search_path = public, auth;

-- Ensure pg_trgm is available for trigram indexes
create extension if not exists pg_trgm;

-- Catalog search performance indexes
create index if not exists products_name_he_trgm_idx
  on public.products using gin ((name ->> 'he') gin_trgm_ops);

create index if not exists products_name_en_trgm_idx
  on public.products using gin ((name ->> 'en') gin_trgm_ops);

create index if not exists products_sku_trgm_idx
  on public.products using gin (sku gin_trgm_ops);

create index if not exists product_variants_sku_trgm_idx
  on public.product_variants using gin (sku gin_trgm_ops);

create index if not exists product_variants_barcode_trgm_idx
  on public.product_variants using gin (barcode gin_trgm_ops);

-- Order and shipment timeline indexes
create index if not exists orders_status_created_idx
  on public.orders (status, created_at desc);

create index if not exists orders_customer_created_idx
  on public.orders (customer_company_id, created_at desc);

create index if not exists shipments_status_created_idx
  on public.shipments (status, created_at desc);

create index if not exists shipments_vendor_created_idx
  on public.shipments (vendor_company_id, created_at desc);

-- Align shipment policies naming & scope
alter table public.shipments enable row level security;

drop policy if exists shipments_vendor_rw on public.shipments;
drop policy if exists shipments_vendor_update on public.shipments;

do $$
begin
  if not exists (
    select 1 from pg_policies
     where schemaname = 'public'
       and tablename  = 'shipments'
       and policyname = 'shipments_vendor_read'
  ) then
    create policy shipments_vendor_read
      on public.shipments
      for select to authenticated
      using (
        auth_role() = any (array['vendor_admin'::user_role, 'vendor_user'::user_role])
        and vendor_company_id = auth_company_id()
      );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from pg_policies
     where schemaname = 'public'
       and tablename  = 'shipments'
       and policyname = 'shipments_vendor_write'
  ) then
    create policy shipments_vendor_write
      on public.shipments
      for update to authenticated
      using (
        auth_role() = any (array['vendor_admin'::user_role, 'vendor_user'::user_role])
        and vendor_company_id = auth_company_id()
      )
      with check (
        auth_role() = any (array['vendor_admin'::user_role, 'vendor_user'::user_role])
        and vendor_company_id = auth_company_id()
      );
  end if;
end$$;
