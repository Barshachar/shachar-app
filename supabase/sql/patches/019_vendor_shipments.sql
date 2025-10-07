set search_path = public, auth;

-- RLS adjustments for vendor shipment access
alter table public.shipments enable row level security;

drop policy if exists shipments_vendor_rw on public.shipments;
drop policy if exists shipments_vendor_read on public.shipments;
drop policy if exists shipments_vendor_update on public.shipments;

create policy shipments_vendor_read
  on public.shipments
  for select to authenticated
  using (
    auth_role() = ANY (ARRAY['vendor_admin'::user_role, 'vendor_user'::user_role])
    and vendor_company_id = auth_company_id()
  );

create policy shipments_vendor_update
  on public.shipments
  for update to authenticated
  using (
    auth_role() = ANY (ARRAY['vendor_admin'::user_role, 'vendor_user'::user_role])
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() = ANY (ARRAY['vendor_admin'::user_role, 'vendor_user'::user_role])
    and vendor_company_id = auth_company_id()
  );

-- RPC for vendor shipment updates

DROP FUNCTION IF EXISTS public.rpc_update_shipment(uuid, text, text);

create or replace function public.rpc_update_shipment(
  p_shipment_id uuid,
  p_status text,
  p_tracking text
) returns uuid as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_vendor uuid := auth_company_id();
  v_shipment_vendor uuid;
  v_current_status shipment_status;
  v_new_status shipment_status;
  v_new_tracking text;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('vendor_admin', 'vendor_user') then
    raise exception 'Only vendor roles may update shipments';
  end if;

  if v_vendor is null then
    raise exception 'Vendor context missing';
  end if;

  select vendor_company_id, status
    into v_shipment_vendor, v_current_status
    from public.shipments
   where id = p_shipment_id
   for update;

  if not found then
    raise exception 'Shipment % not found', p_shipment_id;
  end if;

  if v_shipment_vendor is distinct from v_vendor then
    raise exception 'Shipment % is not accessible for this vendor', p_shipment_id using errcode = '42501';
  end if;

  if p_status is not null then
    begin
      v_new_status := p_status::shipment_status;
    exception when others then
      raise exception 'Invalid shipment status %', p_status using errcode = '22P02';
    end;
  else
    v_new_status := v_current_status;
  end if;

  update public.shipments
     set status = v_new_status,
         tracking = coalesce(p_tracking, tracking),
         updated_at = now()
   where id = p_shipment_id
   returning tracking into v_new_tracking;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'shipment_updated',
    'shipments',
    p_shipment_id,
    jsonb_build_object('status', v_new_status, 'tracking', v_new_tracking)
  );

  return p_shipment_id;
end;
$$ language plpgsql
   security definer
   set search_path = public, auth;

grant execute on function public.rpc_update_shipment(uuid, text, text) to authenticated;
