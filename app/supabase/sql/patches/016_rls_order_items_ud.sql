begin;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'order_items'
      and policyname = 'order_items_customer_update'
  ) then
    create policy order_items_customer_update on public.order_items
      for update to authenticated
      using (
        auth_role() in ('customer_admin'::user_role, 'buyer'::user_role)
        and exists (
          select 1
          from public.orders o
          where o.id = order_items.order_id
            and o.customer_company_id = auth_company_id()
            and o.status = 'draft'
        )
      )
      with check (
        auth_role() in ('customer_admin'::user_role, 'buyer'::user_role)
        and exists (
          select 1
          from public.orders o
          where o.id = order_items.order_id
            and o.customer_company_id = auth_company_id()
            and o.status = 'draft'
        )
      );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'order_items'
      and policyname = 'order_items_customer_delete'
  ) then
    create policy order_items_customer_delete on public.order_items
      for delete to authenticated
      using (
        auth_role() in ('customer_admin'::user_role, 'buyer'::user_role)
        and exists (
          select 1
          from public.orders o
          where o.id = order_items.order_id
            and o.customer_company_id = auth_company_id()
            and o.status = 'draft'
        )
      );
  end if;
end$$;

commit;
