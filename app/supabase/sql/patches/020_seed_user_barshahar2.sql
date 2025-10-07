-- Adds demo buyer account for manual testing.
-- Safe to re-run; statements use ON CONFLICT WHERE appropriate to avoid duplicates.

-- Ensure company exists (defaults to SuperMart Chain).
insert into companies (id, type, status, name, locale, currency, timezone)
values (
    '30000000-0000-0000-0000-000000000000',
    'customer',
    'active',
    'SuperMart Chain',
    'he',
    'ILS',
    'Asia/Jerusalem'
)
on conflict (id) do nothing;

-- Upsert the auth user.
insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change,
    phone_change_token,
    phone_change,
    email_change_token_current,
    reauthentication_token,
    last_sign_in_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at
)
values (
    '00000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-4444-444444444444',
    'authenticated',
    'authenticated',
    'barshahar2@gmail.com',
    crypt('Bar123456', gen_salt('bf', 10)),
    now(),
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    now(),
    jsonb_build_object('sub','44444444-4444-4444-4444-444444444444','email','barshahar2@gmail.com','email_verified',true,'phone_verified',false,'full_name','Bar Shahar','locale','en'),
    jsonb_build_object('provider','email','providers',ARRAY['email']::text[],'role','buyer','company_id','30000000-0000-0000-0000-000000000000','company_type','customer'),
    now(),
    now()
)
on conflict (id) do update
set
    encrypted_password = excluded.encrypted_password,
    email_confirmed_at = excluded.email_confirmed_at,
    confirmation_token = excluded.confirmation_token,
    recovery_token = excluded.recovery_token,
    email_change_token_new = excluded.email_change_token_new,
    email_change = excluded.email_change,
    phone_change_token = excluded.phone_change_token,
    phone_change = excluded.phone_change,
    email_change_token_current = excluded.email_change_token_current,
    reauthentication_token = excluded.reauthentication_token,
    last_sign_in_at = excluded.last_sign_in_at,
    raw_user_meta_data = excluded.raw_user_meta_data,
    raw_app_meta_data = excluded.raw_app_meta_data,
    updated_at = excluded.updated_at;

insert into auth.identities (user_id, provider, provider_id, identity_data, created_at, updated_at)
values (
    '44444444-4444-4444-4444-444444444444',
    'email',
    '44444444-4444-4444-4444-444444444444',
    jsonb_build_object('sub','44444444-4444-4444-4444-444444444444','email','barshahar2@gmail.com','email_verified',true,'phone_verified',false),
    now(),
    now()
)
on conflict (provider_id, provider) do update
set
    user_id = excluded.user_id,
    identity_data = excluded.identity_data,
    updated_at = excluded.updated_at;

-- Bind user to company role table.
insert into company_users (company_id, user_id, role)
values (
    '30000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-4444-444444444444',
    'buyer'
)
on conflict (company_id, user_id) do update set role = excluded.role;
