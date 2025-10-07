set search_path = public, auth;

drop function if exists public.rpc_reorder(uuid);

create or replace function public.rpc_reorder(p_order_id uuid)
returns uuid as $$
declare
  v_user uuid := auth.uid();
  v_company uuid := auth_company_id();
  v_role user_role := auth_role();
  v_source_company uuid;
  v_currency text;
  v_new_order uuid;
  v_line record;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('customer_admin', 'buyer') then
    raise exception 'Only customer roles may reorder';
  end if;

  select customer_company_id, currency
    into v_source_company, v_currency
    from public.orders
   where id = p_order_id;

  if not found then
    raise exception 'Order % not found', p_order_id;
  end if;

  if v_source_company is distinct from v_company then
    raise exception 'Tenant violation for order %', p_order_id using errcode = '42501';
  end if;

  insert into public.orders (customer_company_id, created_by, status, currency)
  values (v_company, v_user, 'draft', coalesce(v_currency, 'ILS'))
  returning id into v_new_order;

  for v_line in
    select variant_id, sum(qty) as qty
      from public.order_items
     where order_id = p_order_id
       and qty > 0
     group by variant_id
  loop
    perform public.rpc_add_line(v_new_order, v_line.variant_id, v_line.qty);
  end loop;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'order_reordered',
    'orders',
    v_new_order,
    jsonb_build_object('source_order_id', p_order_id)
  );

  return v_new_order;
end;
$$ language plpgsql
   security definer
   set search_path = public, auth;

grant execute on function public.rpc_reorder(uuid) to authenticated;
