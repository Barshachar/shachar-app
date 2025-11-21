set search_path = public, auth;

-- Ensure company_users has an active flag for admin controls
do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'company_users'
       and column_name = 'active'
  ) then
    alter table company_users
      add column active boolean not null default true;
  end if;
end;
$$;

create or replace function admin_list_company_users(p_company_id uuid default null)
returns table (
  user_id uuid,
  email text,
  full_name text,
  role user_role,
  company_id uuid,
  company_name text,
  company_type company_type,
  invited_at timestamptz,
  last_sign_in_at timestamptz,
  banned_until timestamptz,
  status text
)
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_company uuid := coalesce(p_company_id, auth_company_id());
begin
  if v_company is null then
    raise exception 'admin_list_company_users missing tenant scope'
      using errcode = '22023';
  end if;

  return query
    select cu.user_id,
           u.email,
           coalesce(u.raw_user_meta_data->>'full_name', '') as full_name,
           cu.role,
           cu.company_id,
           c.name as company_name,
           c.type as company_type,
           cu.created_at as invited_at,
           u.last_sign_in_at,
           u.banned_until,
           case
             when cu.active is false then 'disabled'
             when u.banned_until is not null and u.banned_until > now() then 'disabled'
             else 'active'
           end as status
      from company_users cu
      join auth.users u on u.id = cu.user_id
      join companies c on c.id = cu.company_id
     where cu.company_id = v_company
     order by lower(u.email);
end;
$$;

grant execute on function admin_list_company_users(uuid) to authenticated, service_role;

create or replace function admin_set_user_role(
  p_company_id uuid,
  p_user_id uuid,
  p_role user_role,
  p_active boolean default true,
  p_actor uuid default null,
  p_reason text default null
) returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_company uuid := coalesce(p_company_id, auth_company_id());
  v_actor uuid := coalesce(p_actor, auth.uid());
begin
  if v_company is null then
    raise exception 'admin_set_user_role missing tenant scope'
      using errcode = '22023';
  end if;

  insert into company_users(company_id, user_id, role, active)
  values (v_company, p_user_id, p_role, coalesce(p_active, true))
  on conflict(company_id, user_id) do update
    set role = excluded.role,
        active = excluded.active;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_actor,
    'admin_set_user_role',
    'company_users',
    p_user_id,
    jsonb_build_object(
      'company_id', v_company,
      'role', p_role,
      'active', coalesce(p_active, true),
      'reason', p_reason
    )
  );
end;
$$;

grant execute on function admin_set_user_role(uuid, uuid, user_role, boolean, uuid, text) to service_role;
