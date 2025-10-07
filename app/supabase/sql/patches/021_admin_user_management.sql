-- Admin user management helpers
BEGIN;
SET search_path = public, auth;

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
  v_role user_role := auth_role();
  v_company uuid := coalesce(p_company_id, auth_company_id());
begin
  if v_role is distinct from 'admin' then
    raise exception 'admin_list_company_users requires admin role'
      using errcode = '42501';
  end if;

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

COMMIT;
