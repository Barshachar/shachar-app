set search_path = public, auth, extensions;

create table if not exists vendor_ratings (
  id uuid primary key default uuid_generate_v4(),
  vendor_company_id uuid not null references companies(id) on delete cascade,
  customer_company_id uuid not null references companies(id) on delete cascade,
  order_id uuid not null references orders(id) on delete cascade,
  rating int not null,
  comment text,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vendor_ratings_rating_range check (rating >= 1 and rating <= 5),
  constraint vendor_ratings_unique unique (order_id, vendor_company_id, customer_company_id)
);

create index if not exists vendor_ratings_vendor_idx
  on vendor_ratings(vendor_company_id, created_at desc);
create index if not exists vendor_ratings_customer_idx
  on vendor_ratings(customer_company_id, created_at desc);
create index if not exists vendor_ratings_order_idx
  on vendor_ratings(order_id);

create or replace view vendor_rating_summary with (security_barrier=true) as
select
  vendor_company_id,
  round(avg(rating)::numeric, 2) as average_rating,
  count(*)::int as ratings_count,
  max(created_at) as last_rating_at
from vendor_ratings
where auth_role() is not null
group by vendor_company_id;

grant select on vendor_rating_summary to authenticated;

alter table vendor_ratings enable row level security;

drop policy if exists vendor_ratings_admin_all on vendor_ratings;
create policy vendor_ratings_admin_all on vendor_ratings
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

drop policy if exists vendor_ratings_customer_select on vendor_ratings;
create policy vendor_ratings_customer_select on vendor_ratings
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

drop policy if exists vendor_ratings_vendor_select on vendor_ratings;
create policy vendor_ratings_vendor_select on vendor_ratings
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

drop policy if exists vendor_ratings_customer_insert on vendor_ratings;
create policy vendor_ratings_customer_insert on vendor_ratings
  for insert to authenticated
  with check (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
    and created_by = auth.uid()
    and exists (
      select 1
        from orders o
       where o.id = order_id
         and o.customer_company_id = auth_company_id()
    )
    and exists (
      select 1
        from order_items oi
       where oi.order_id = order_id
         and oi.vendor_company_id = vendor_company_id
    )
  );
