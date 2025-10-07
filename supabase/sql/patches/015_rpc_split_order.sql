create or replace function rpc_split_order(p_order_id uuid)
returns integer as $$
declare
  v_cnt int := 0;
begin
  if p_order_id is null then
    raise exception 'order_id required';
  end if;

  -- אם כבר יש משלוחים להזמנה – החזר ספירה קיימת
  select count(*) into v_cnt from public.shipments s where s.order_id = p_order_id;
  if v_cnt > 0 then
    return v_cnt;
  end if;

  -- צור משלוח אחד לכל ספק שיש לו שורות בהזמנה
  insert into public.shipments(order_id, vendor_company_id, status)
  select oi.order_id, oi.vendor_company_id, 'pending'
  from public.order_items oi
  where oi.order_id = p_order_id
  group by oi.order_id, oi.vendor_company_id;

  select count(*) into v_cnt from public.shipments s where s.order_id = p_order_id;
  return v_cnt;
end;
$$ language plpgsql
security definer
set search_path = public, auth;
