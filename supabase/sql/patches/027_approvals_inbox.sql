set search_path = public, auth;

create or replace view order_approvals_inbox as
select
  ar.id as step_id,
  ar.entity_id as order_id,
  o.order_number,
  o.total,
  o.currency,
  ar.created_at as requested_at,
  ar.status,
  coalesce(u.raw_user_meta_data->>'full_name', u.email) as requested_by,
  c.name as buyer_name,
  ar.notes as note
from approval_requests ar
join orders o on o.id = ar.entity_id
join companies c on c.id = ar.company_id
left join auth.users u on u.id = ar.requester_user_id
where ar.entity_type = 'order'
  and ar.status = 'pending'
  and (
    auth_role() = 'admin'
    or (
      ar.company_id = auth_company_id()
      and ar.approver_user_id = auth.uid()
    )
  );

grant select on order_approvals_inbox to authenticated;

DROP FUNCTION IF EXISTS rpc_approvals_inbox();
CREATE OR REPLACE FUNCTION rpc_approvals_inbox()
RETURNS TABLE (
  step_id uuid,
  order_id uuid,
  order_number text,
  total numeric,
  currency text,
  requested_at timestamptz,
  status text,
  requested_by text,
  buyer_name text,
  note text
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, auth
AS $$
  select
    step_id,
    order_id,
    order_number,
    total,
    currency,
    requested_at,
    status,
    requested_by,
    buyer_name,
    note
  from order_approvals_inbox
  order by requested_at desc;
$$;

grant execute on function rpc_approvals_inbox() to authenticated;

DROP FUNCTION IF EXISTS rpc_evaluate_approvals(uuid);
CREATE OR REPLACE FUNCTION rpc_evaluate_approvals(p_order_id uuid)
RETURNS jsonb AS $$
DECLARE
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_order orders%rowtype;
  v_request approval_requests%rowtype;
  v_approver uuid;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('admin','customer_admin','buyer') then
    raise exception 'Role % not permitted for approvals', v_role;
  end if;

  select *
    into v_order
    from orders
   where id = p_order_id;

  if not found then
    raise exception 'Order % not found', p_order_id;
  end if;

  if v_role <> 'admin' and v_order.customer_company_id <> v_company then
    raise exception 'Tenant violation for order %', p_order_id using errcode = '42501';
  end if;

  select *
    into v_request
    from approval_requests
   where entity_type = 'order'
     and entity_id = p_order_id
   order by created_at desc
   limit 1;

  if v_request.id is not null then
    return jsonb_build_object(
      'order_id', p_order_id,
      'request_id', v_request.id,
      'status', v_request.status,
      'requested_at', v_request.created_at,
      'approver_user_id', v_request.approver_user_id
    );
  end if;

  select cu.user_id
    into v_approver
    from company_users cu
   where cu.company_id = v_order.customer_company_id
     and cu.role = 'customer_admin'
     and cu.user_id <> v_user
   order by cu.user_id
   limit 1;

  if v_approver is null then
    v_approver := v_user;
  end if;

  insert into approval_requests (
    requester_user_id,
    approver_user_id,
    company_id,
    request_type,
    entity_type,
    entity_id,
    status,
    notes,
    created_at,
    updated_at
  )
  values (
    v_user,
    v_approver,
    v_order.customer_company_id,
    'order_approval',
    'order',
    p_order_id,
    'pending',
    null,
    now(),
    now()
  )
  returning * into v_request;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'approval_request_created',
    'approval_requests',
    v_request.id,
    jsonb_build_object('order_id', p_order_id, 'approver_user_id', v_approver)
  );

  return jsonb_build_object(
    'order_id', p_order_id,
    'request_id', v_request.id,
    'status', v_request.status,
    'requested_at', v_request.created_at,
    'approver_user_id', v_approver
  );
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

grant execute on function rpc_evaluate_approvals(uuid) to authenticated;

DROP FUNCTION IF EXISTS rpc_approve_step(uuid, uuid, text, text);
CREATE OR REPLACE FUNCTION rpc_approve_step(
  p_step_id uuid,
  p_order_id uuid,
  p_decision text,
  p_note text
) RETURNS jsonb AS $$
DECLARE
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_request approval_requests%rowtype;
  v_status text;
BEGIN
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  select *
    into v_request
    from approval_requests
   where id = p_step_id
   for update;

  if not found then
    raise exception 'Approval request % not found', p_step_id;
  end if;

  if v_role <> 'admin' then
    if v_request.company_id <> v_company then
      raise exception 'Tenant violation for request %', p_step_id using errcode = '42501';
    end if;

    if v_request.approver_user_id <> v_user then
      raise exception 'Request % assigned to a different approver', p_step_id using errcode = '42501';
    end if;
  end if;

  if v_request.entity_type <> 'order' or v_request.entity_id <> p_order_id then
    raise exception 'Approval request % does not match order %', p_step_id, p_order_id;
  end if;

  if v_request.status <> 'pending' then
    raise exception 'Approval request already resolved';
  end if;

  if p_decision is null then
    raise exception 'Decision required';
  end if;

  if lower(p_decision) in ('approve','approved','accept') then
    v_status := 'approved';
  elsif lower(p_decision) in ('reject','rejected','decline','denied') then
    v_status := 'rejected';
  else
    raise exception 'Unknown decision %', p_decision;
  end if;

  update approval_requests
     set status = v_status,
         notes = coalesce(nullif(p_note, ''), notes),
         reviewed_at = now(),
         updated_at = now()
   where id = v_request.id
   returning * into v_request;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    case when v_status = 'approved' then 'approval_request_approved' else 'approval_request_rejected' end,
    'approval_requests',
    v_request.id,
    jsonb_build_object('order_id', v_request.entity_id, 'decision', v_status)
  );

  return jsonb_build_object(
    'request_id', v_request.id,
    'order_id', v_request.entity_id,
    'status', v_request.status,
    'reviewed_at', v_request.reviewed_at
  );
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public, auth;

grant execute on function rpc_approve_step(uuid, uuid, text, text) to authenticated;
