set search_path = public, auth;

-- Enumerations for RFQ lifecycle and vendor quote flow
do $$
begin
  if not exists (
    select 1
      from pg_type t
      join pg_namespace n on n.oid = t.typnamespace
     where t.typname = 'rfq_state'
       and n.nspname = 'public'
  ) then
    create type public.rfq_state as enum (
      'draft',
      'issued',
      'in_review',
      'awarded',
      'cancelled',
      'expired'
    );
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
      from pg_type t
      join pg_namespace n on n.oid = t.typnamespace
     where t.typname = 'quote_state'
       and n.nspname = 'public'
  ) then
    create type public.quote_state as enum (
      'draft',
      'invited',
      'submitted',
      'withdrawn',
      'awarded',
      'declined'
    );
  end if;
end$$;

-- Core RFQ tables
create table public.rfqs (
    id uuid primary key default uuid_generate_v4(),
    customer_company_id uuid not null references public.companies(id) on delete cascade,
    created_by uuid not null references auth.users(id),
    status public.rfq_state not null default 'draft',
    title text not null,
    notes text,
    currency text not null default 'ILS',
    response_due_at timestamptz,
    invited_vendor_ids uuid[] not null default '{}'::uuid[],
    meta jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    rfq_number text generated always as (upper(replace(id::text, '-', ''))) stored,
    constraint rfqs_meta_is_object check (jsonb_typeof(meta) = 'object')
);
create index rfqs_customer_idx on public.rfqs(customer_company_id, created_at desc);
create index rfqs_status_idx on public.rfqs(status, created_at desc);
create index rfqs_invited_vendor_ids_idx on public.rfqs using gin(invited_vendor_ids);

create table public.rfq_items (
    id uuid primary key default uuid_generate_v4(),
    rfq_id uuid not null references public.rfqs(id) on delete cascade,
    line_number int not null,
    variant_id uuid references public.product_variants(id) on delete set null,
    description text,
    requested_qty numeric(14,3) not null default 1,
    requested_uom text not null default 'EA',
    target_price numeric(12,2),
    meta jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint rfq_items_line_unique unique (rfq_id, line_number),
    constraint rfq_items_meta_is_object check (jsonb_typeof(meta) = 'object')
);
create index rfq_items_rfq_idx on public.rfq_items(rfq_id);

create table public.quotes (
    id uuid primary key default uuid_generate_v4(),
    rfq_id uuid not null references public.rfqs(id) on delete cascade,
    vendor_company_id uuid not null references public.companies(id) on delete cascade,
    submitted_by uuid references auth.users(id),
    status public.quote_state not null default 'draft',
    currency text not null default 'ILS',
    terms jsonb not null default '{}'::jsonb,
    subtotal numeric(14,2) not null default 0,
    tax_total numeric(14,2) not null default 0,
    total numeric(14,2) not null default 0,
    submitted_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint quotes_terms_is_object check (jsonb_typeof(terms) = 'object'),
    unique (rfq_id, vendor_company_id)
);
create index quotes_rfq_idx on public.quotes(rfq_id);
create index quotes_vendor_idx on public.quotes(vendor_company_id, status);

create table public.quote_items (
    id uuid primary key default uuid_generate_v4(),
    quote_id uuid not null references public.quotes(id) on delete cascade,
    rfq_item_id uuid not null references public.rfq_items(id) on delete cascade,
    offered_variant_id uuid references public.product_variants(id) on delete set null,
    qty numeric(14,3) not null,
    uom text not null default 'EA',
    unit_price numeric(12,2) not null,
    tax_rate numeric(5,2) not null default 17,
    lead_time_days int,
    meta jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    constraint quote_items_meta_is_object check (jsonb_typeof(meta) = 'object'),
    constraint quote_items_unique_per_rfq_item unique (quote_id, rfq_item_id)
);
create index quote_items_quote_idx on public.quote_items(quote_id);

create table public.rfq_messages (
    id uuid primary key default uuid_generate_v4(),
    rfq_id uuid not null references public.rfqs(id) on delete cascade,
    author_user_id uuid not null references auth.users(id),
    audience text not null default 'all',
    message text not null,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    constraint rfq_messages_audience_check check (audience in ('all','buyer','vendor','internal')),
    constraint rfq_messages_meta_is_object check (jsonb_typeof(metadata) = 'object')
);
create index rfq_messages_rfq_idx on public.rfq_messages(rfq_id, created_at desc);

create table public.rfq_status (
    id uuid primary key default uuid_generate_v4(),
    rfq_id uuid not null references public.rfqs(id) on delete cascade,
    status public.rfq_state not null,
    set_by uuid references auth.users(id),
    note text,
    created_at timestamptz not null default now()
);
create index rfq_status_rfq_idx on public.rfq_status(rfq_id, created_at desc);

-- Helper functions
create or replace function public.fn_touch_updated_at()
returns trigger
language plpgsql
set search_path = public, auth
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.rfq_customer_has_access(p_rfq_id uuid, p_company uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
      from public.rfqs r
     where r.id = p_rfq_id
       and r.customer_company_id = p_company
  );
$$;
grant execute on function public.rfq_customer_has_access(uuid, uuid) to authenticated, service_role;

create or replace function public.rfq_vendor_has_access(p_rfq_id uuid, p_vendor uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
      from public.rfqs r
     where r.id = p_rfq_id
       and (
         p_vendor = any (coalesce(r.invited_vendor_ids, array[]::uuid[]))
         or exists (
             select 1
               from public.quotes q
              where q.rfq_id = r.id
                and q.vendor_company_id = p_vendor
           )
       )
  );
$$;
grant execute on function public.rfq_vendor_has_access(uuid, uuid) to authenticated, service_role;

create or replace function public.fn_rfq_status_log()
returns trigger
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_actor uuid;
  v_note text;
begin
  v_actor := coalesce(auth.uid(), coalesce(new.created_by, old.created_by));
  if tg_op = 'INSERT' then
    v_note := coalesce(new.meta->>'status_note', null);
    insert into public.rfq_status(rfq_id, status, set_by, note)
    values (new.id, new.status, v_actor, v_note);
  elsif tg_op = 'UPDATE' and new.status is distinct from old.status then
    v_note := coalesce(new.meta->>'status_note', null);
    insert into public.rfq_status(rfq_id, status, set_by, note)
    values (new.id, new.status, v_actor, v_note);
  end if;
  return new;
end;
$$;

-- Triggers
create trigger rfqs_touch_updated_at
  before update on public.rfqs
  for each row
  execute function public.fn_touch_updated_at();

create trigger rfq_items_touch_updated_at
  before update on public.rfq_items
  for each row
  execute function public.fn_touch_updated_at();

create trigger quotes_touch_updated_at
  before update on public.quotes
  for each row
  execute function public.fn_touch_updated_at();

create trigger rfqs_status_audit_trg
  after insert or update of status on public.rfqs
  for each row
  execute function public.fn_rfq_status_log();

-- Row Level Security
alter table public.rfqs enable row level security;
alter table public.rfq_items enable row level security;
alter table public.quotes enable row level security;
alter table public.quote_items enable row level security;
alter table public.rfq_messages enable row level security;
alter table public.rfq_status enable row level security;

-- RFQs policies
create policy rfqs_admin_all on public.rfqs
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy rfqs_customer_read on public.rfqs
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

create policy rfqs_customer_insert on public.rfqs
  for insert to authenticated
  with check (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

create policy rfqs_customer_update on public.rfqs
  for update to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('customer_admin','buyer')
    and customer_company_id = auth_company_id()
  );

create policy rfqs_customer_delete on public.rfqs
  for delete to authenticated
  using (
    auth_role() = 'customer_admin'
    and customer_company_id = auth_company_id()
  );

create policy rfqs_vendor_read on public.rfqs
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and public.rfq_vendor_has_access(id, auth_company_id())
  );

-- RFQ items policies
create policy rfq_items_admin_all on public.rfq_items
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy rfq_items_customer_read on public.rfq_items
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

create policy rfq_items_customer_insert on public.rfq_items
  for insert to authenticated
  with check (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

create policy rfq_items_customer_update on public.rfq_items
  for update to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  )
  with check (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

create policy rfq_items_customer_delete on public.rfq_items
  for delete to authenticated
  using (
    auth_role() = 'customer_admin'
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

create policy rfq_items_vendor_read on public.rfq_items
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and public.rfq_vendor_has_access(rfq_id, auth_company_id())
  );

-- Quotes policies
create policy quotes_admin_all on public.quotes
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy quotes_vendor_rw on public.quotes
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and vendor_company_id = auth_company_id()
  );

create policy quotes_customer_read on public.quotes
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

-- Quote items policies
create policy quote_items_admin_all on public.quote_items
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy quote_items_vendor_rw on public.quote_items
  for all to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.quotes q
       where q.id = quote_items.quote_id
         and q.vendor_company_id = auth_company_id()
    )
  )
  with check (
    auth_role() in ('vendor_admin','vendor_user')
    and exists (
      select 1
        from public.quotes q
       where q.id = quote_items.quote_id
         and q.vendor_company_id = auth_company_id()
    )
  );

create policy quote_items_customer_read on public.quote_items
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and exists (
      select 1
        from public.quotes q
       where q.id = quote_items.quote_id
         and public.rfq_customer_has_access(q.rfq_id, auth_company_id())
    )
  );

-- RFQ messages policies
create policy rfq_messages_admin_all on public.rfq_messages
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy rfq_messages_participant_read on public.rfq_messages
  for select to authenticated
  using (
    (
      auth_role() in ('customer_admin','buyer')
      and public.rfq_customer_has_access(rfq_id, auth_company_id())
      and audience in ('all','buyer')
    )
    or (
      auth_role() in ('vendor_admin','vendor_user')
      and public.rfq_vendor_has_access(rfq_id, auth_company_id())
      and audience in ('all','vendor')
    )
  );

create policy rfq_messages_participant_insert on public.rfq_messages
  for insert to authenticated
  with check (
    (
      auth_role() in ('customer_admin','buyer')
      and public.rfq_customer_has_access(rfq_id, auth_company_id())
      and audience in ('all','buyer')
      and author_user_id = auth.uid()
    )
    or (
      auth_role() in ('vendor_admin','vendor_user')
      and public.rfq_vendor_has_access(rfq_id, auth_company_id())
      and audience in ('all','vendor')
      and author_user_id = auth.uid()
    )
  );

-- RFQ status policies
create policy rfq_status_admin_all on public.rfq_status
  for all using (auth_role() = 'admin') with check (auth_role() = 'admin');

create policy rfq_status_customer_read on public.rfq_status
  for select to authenticated
  using (
    auth_role() in ('customer_admin','buyer')
    and public.rfq_customer_has_access(rfq_id, auth_company_id())
  );

create policy rfq_status_vendor_read on public.rfq_status
  for select to authenticated
  using (
    auth_role() in ('vendor_admin','vendor_user')
    and public.rfq_vendor_has_access(rfq_id, auth_company_id())
  );

-- RLS regression smoke tests
set local role authenticated;
set session "request.jwt.claims" = '{ "role": "vendor_admin", "company_id": "20000000-0000-0000-0000-000000000000", "sub": "22222222-2222-2222-2222-222222222222" }';

DO $$
DECLARE
  leak uuid;
BEGIN
  SELECT r.id
    INTO leak
    FROM public.rfqs r
   WHERE r.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: vendor can read foreign RFQ %', leak;
  END IF;
END$$;

DO $$
DECLARE
  leak uuid;
BEGIN
  SELECT q.id
    INTO leak
    FROM public.quotes q
    JOIN public.rfqs r ON r.id = q.rfq_id
   WHERE r.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: vendor can read foreign quote %', leak;
  END IF;
END$$;

reset role;
reset session "request.jwt.claims";

set local role authenticated;
set session "request.jwt.claims" = '{ "role": "buyer", "company_id": "30000000-0000-0000-0000-000000000000", "sub": "33333333-3333-3333-3333-333333333333" }';

DO $$
DECLARE
  leak uuid;
BEGIN
  SELECT r.id
    INTO leak
    FROM public.rfqs r
   WHERE r.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: customer can read foreign RFQ %', leak;
  END IF;
END$$;

DO $$
DECLARE
  leak uuid;
BEGIN
  SELECT q.id
    INTO leak
    FROM public.quotes q
    JOIN public.rfqs r ON r.id = q.rfq_id
   WHERE r.customer_company_id <> auth_company_id()
   LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'RLS violation: customer can read foreign quote %', leak;
  END IF;
END$$;

reset role;
reset session "request.jwt.claims";

-- RPC: create RFQ
create or replace function public.rpc_create_rfq(
  p_company_id uuid,
  p_items jsonb,
  p_meta jsonb default '{}'::jsonb
) returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_rfq_id uuid;
  v_item_record record;
  v_item jsonb;
  v_meta jsonb := coalesce(p_meta, '{}'::jsonb);
  v_items jsonb := coalesce(p_items, '[]'::jsonb);
  v_title text;
  v_currency text := 'ILS';
  v_notes text;
  v_due timestamptz;
  v_invited uuid[] := array[]::uuid[];
  v_variant uuid;
  v_target numeric;
  v_qty numeric;
  v_line_no int;
  v_uom text;
  v_description text;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('admin','customer_admin','buyer') then
    raise exception 'Only customer buyers may create RFQs' using errcode = '42501';
  end if;

  if p_company_id is null then
    raise exception 'company_id is required' using errcode = '22004';
  end if;

  if v_role <> 'admin' and v_company <> p_company_id then
    raise exception 'company_id does not match session company' using errcode = '42501';
  end if;

  if jsonb_typeof(v_items) <> 'array' or jsonb_array_length(v_items) = 0 then
    raise exception 'items must be a non-empty JSON array' using errcode = '22023';
  end if;

  v_title := coalesce(nullif(v_meta->>'title', ''), 'RFQ Draft');
  v_currency := coalesce(nullif(v_meta->>'currency', ''), 'ILS');
  v_notes := nullif(v_meta->>'notes', '');

  if v_meta ? 'response_due_at' then
    begin
      v_due := (v_meta->>'response_due_at')::timestamptz;
    exception when others then
      raise exception 'Invalid response_due_at value %', v_meta->>'response_due_at' using errcode = '22P02';
    end;
  end if;

  if v_meta ? 'invited_vendor_ids' then
    v_invited := array(
      select value::uuid
        from jsonb_array_elements_text(v_meta->'invited_vendor_ids') as value
    );
  end if;

  insert into public.rfqs (customer_company_id, created_by, status, title, notes, currency, response_due_at, invited_vendor_ids, meta)
  values (p_company_id, v_user, 'draft', v_title, v_notes, v_currency, v_due, coalesce(v_invited, array[]::uuid[]), v_meta)
  returning id into v_rfq_id;

  for v_item_record in
    select elem, idx
      from jsonb_array_elements(v_items) with ordinality as t(elem, idx)
  loop
    v_item := v_item_record.elem;

    if v_item ? 'line_number' then
      begin
        v_line_no := (v_item->>'line_number')::int;
      exception when others then
        raise exception 'Invalid line_number in RFQ item payload %', v_item->>'line_number' using errcode = '22P02';
      end;
    else
      v_line_no := v_item_record.idx;
    end if;

    if v_item ? 'variant_id' and nullif(v_item->>'variant_id', '') is not null then
      begin
        v_variant := (v_item->>'variant_id')::uuid;
      exception when others then
        raise exception 'Invalid variant_id in RFQ item: %', v_item->>'variant_id' using errcode = '22P02';
      end;
    else
      v_variant := null;
    end if;

    if v_item ? 'target_price' then
      begin
        v_target := (v_item->>'target_price')::numeric;
      exception when others then
        raise exception 'Invalid target_price in RFQ item line %', v_line_no using errcode = '22P02';
      end;
    else
      v_target := null;
    end if;

    if v_item ? 'requested_qty' and nullif(v_item->>'requested_qty', '') is not null then
      begin
        v_qty := (v_item->>'requested_qty')::numeric;
      exception when others then
        raise exception 'Invalid requested_qty in RFQ item line %', v_line_no using errcode = '22P02';
      end;
    else
      v_qty := 1;
    end if;

    if v_qty <= 0 then
      raise exception 'requested_qty must be positive for RFQ item line %', v_line_no using errcode = '22013';
    end if;

    v_uom := coalesce(nullif(v_item->>'requested_uom', ''), 'EA');
    v_description := nullif(v_item->>'description', '');

    insert into public.rfq_items (
      rfq_id,
      line_number,
      variant_id,
      description,
      requested_qty,
      requested_uom,
      target_price,
      meta
    )
    values (
      v_rfq_id,
      v_line_no,
      v_variant,
      v_description,
      v_qty,
      v_uom,
      v_target,
      coalesce(v_item, '{}'::jsonb)
    );
  end loop;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'rfq_created',
    'rfqs',
    v_rfq_id,
    jsonb_build_object(
      'company_id', p_company_id,
      'item_count', jsonb_array_length(v_items),
      'title', v_title
    )
  );

  return v_rfq_id;
end;
$$;
grant execute on function public.rpc_create_rfq(uuid, jsonb, jsonb) to authenticated;

-- RPC: vendor submit quote
create or replace function public.rpc_vendor_submit_quote(
  p_rfq_id uuid,
  p_items jsonb,
  p_terms jsonb default '{}'::jsonb
) returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_vendor uuid := auth_company_id();
  v_quote_id uuid;
  v_rfq record;
  v_terms jsonb := coalesce(p_terms, '{}'::jsonb);
  v_items jsonb := coalesce(p_items, '[]'::jsonb);
  v_default_tax numeric(5,2) := 17;
  v_currency text;
  v_item_record record;
  v_item jsonb;
  v_rfq_item record;
  v_rfq_item_id uuid;
  v_qty numeric;
  v_price numeric;
  v_tax numeric;
  v_lead int;
  v_variant uuid;
  v_line_subtotal numeric;
  v_subtotal numeric := 0;
  v_tax_total numeric := 0;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('vendor_admin','vendor_user') then
    raise exception 'Only vendor roles may submit quotes' using errcode = '42501';
  end if;

  if v_vendor is null then
    raise exception 'Vendor context missing' using errcode = '42501';
  end if;

  if p_rfq_id is null then
    raise exception 'rfq_id is required' using errcode = '22004';
  end if;

  if jsonb_typeof(v_items) <> 'array' or jsonb_array_length(v_items) = 0 then
    raise exception 'items must be a non-empty JSON array' using errcode = '22023';
  end if;

  select r.*, r.currency as rfq_currency
    into v_rfq
    from public.rfqs r
   where r.id = p_rfq_id
   for update;

  if not found then
    raise exception 'RFQ % not found', p_rfq_id;
  end if;

  if not public.rfq_vendor_has_access(p_rfq_id, v_vendor) then
    raise exception 'Vendor % is not assigned to RFQ %', v_vendor, p_rfq_id using errcode = '42501';
  end if;

  if v_terms ? 'tax_rate' then
    begin
      v_default_tax := (v_terms->>'tax_rate')::numeric;
    exception when others then
      raise exception 'Invalid tax_rate in terms' using errcode = '22P02';
    end;
  end if;

  v_currency := coalesce(nullif(v_terms->>'currency', ''), v_rfq.currency);

  insert into public.quotes (
    rfq_id,
    vendor_company_id,
    submitted_by,
    status,
    currency,
    terms
  )
  values (
    p_rfq_id,
    v_vendor,
    v_user,
    'submitted',
    v_currency,
    v_terms
  )
  on conflict (rfq_id, vendor_company_id) do update
  set submitted_by = excluded.submitted_by,
      submitted_at = now(),
      status = 'submitted',
      currency = excluded.currency,
      terms = excluded.terms,
      updated_at = now()
  returning id into v_quote_id;

  delete from public.quote_items where quote_id = v_quote_id;

  for v_item_record in
    select elem, idx
      from jsonb_array_elements(v_items) with ordinality as t(elem, idx)
  loop
    v_item := v_item_record.elem;

    if not (v_item ? 'rfq_item_id') then
      raise exception 'rfq_item_id is required for quote item at position %', v_item_record.idx using errcode = '22023';
    end if;

    begin
      v_rfq_item_id := (v_item->>'rfq_item_id')::uuid;
    exception when others then
      raise exception 'Invalid rfq_item_id % for quote item position %', v_item->>'rfq_item_id', v_item_record.idx using errcode = '22P02';
    end;

    select ri.*, ri.variant_id as rfq_variant_id
      into v_rfq_item
      from public.rfq_items ri
     where ri.id = v_rfq_item_id
       and ri.rfq_id = p_rfq_id;

    if v_rfq_item.id is null then
      raise exception 'rfq_item_id % is not part of RFQ %', v_rfq_item_id, p_rfq_id using errcode = '42501';
    end if;

    if v_item ? 'qty' and nullif(v_item->>'qty', '') is not null then
      begin
        v_qty := (v_item->>'qty')::numeric;
      exception when others then
        raise exception 'Invalid qty for RFQ item %', v_rfq_item_id using errcode = '22P02';
      end;
    else
      v_qty := v_rfq_item.requested_qty;
    end if;

    if v_qty <= 0 then
      raise exception 'qty must be positive for RFQ item %', v_rfq_item_id using errcode = '22013';
    end if;

    begin
      v_price := (v_item->>'unit_price')::numeric;
    exception when others then
      raise exception 'unit_price is required for RFQ item %', v_rfq_item_id using errcode = '22P02';
    end;

    if v_price <= 0 then
      raise exception 'unit_price must be positive for RFQ item %', v_rfq_item_id using errcode = '22013';
    end if;

    if v_item ? 'tax_rate' and nullif(v_item->>'tax_rate', '') is not null then
      begin
        v_tax := (v_item->>'tax_rate')::numeric;
      exception when others then
        raise exception 'Invalid tax_rate for RFQ item %', v_rfq_item_id using errcode = '22P02';
      end;
    else
      v_tax := v_default_tax;
    end if;

    if v_tax < 0 then
      raise exception 'tax_rate must be non-negative for RFQ item %', v_rfq_item_id using errcode = '22013';
    end if;

    if v_item ? 'lead_time_days' and nullif(v_item->>'lead_time_days', '') is not null then
      begin
        v_lead := (v_item->>'lead_time_days')::int;
      exception when others then
        raise exception 'Invalid lead_time_days for RFQ item %', v_rfq_item_id using errcode = '22P02';
      end;
    else
      v_lead := null;
    end if;

    if v_item ? 'offered_variant_id' and nullif(v_item->>'offered_variant_id', '') is not null then
      begin
        v_variant := (v_item->>'offered_variant_id')::uuid;
      exception when others then
        raise exception 'Invalid offered_variant_id for RFQ item %', v_rfq_item_id using errcode = '22P02';
      end;
    else
      v_variant := null;
    end if;

    insert into public.quote_items (
      quote_id,
      rfq_item_id,
      offered_variant_id,
      qty,
      uom,
      unit_price,
      tax_rate,
      lead_time_days,
      meta
    )
    values (
      v_quote_id,
      v_rfq_item.id,
      v_variant,
      v_qty,
      coalesce(nullif(v_item->>'uom', ''), v_rfq_item.requested_uom),
      v_price,
      v_tax,
      v_lead,
      coalesce(v_item, '{}'::jsonb)
    );

    v_line_subtotal := v_qty * v_price;
    v_subtotal := v_subtotal + v_line_subtotal;
    v_tax_total := v_tax_total + (v_line_subtotal * v_tax / 100);
  end loop;

  update public.quotes
     set subtotal = v_subtotal,
         tax_total = v_tax_total,
         total = v_subtotal + v_tax_total,
         submitted_by = v_user,
         submitted_at = now(),
         status = 'submitted',
         currency = v_currency,
         terms = v_terms,
         updated_at = now()
   where id = v_quote_id;

  if v_rfq.status in ('draft','issued') then
    update public.rfqs
       set status = 'in_review',
           updated_at = now()
     where id = p_rfq_id;
  end if;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'quote_submitted',
    'quotes',
    v_quote_id,
    jsonb_build_object(
      'rfq_id', p_rfq_id,
      'subtotal', v_subtotal,
      'tax_total', v_tax_total,
      'total', v_subtotal + v_tax_total
    )
  );

  return v_quote_id;
end;
$$;
grant execute on function public.rpc_vendor_submit_quote(uuid, jsonb, jsonb) to authenticated;

-- RPC: customer accept quote
create or replace function public.rpc_customer_accept_quote(
  p_quote_id uuid
) returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user uuid := auth.uid();
  v_role user_role := auth_role();
  v_company uuid := auth_company_id();
  v_quote record;
  v_order_id uuid;
  v_currency text;
  v_subtotal numeric := 0;
  v_tax_total numeric := 0;
  v_item record;
  v_variant uuid;
  v_line_subtotal numeric;
  v_tax numeric;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_role not in ('admin','customer_admin','buyer') then
    raise exception 'Only customer buyers may accept quotes' using errcode = '42501';
  end if;

  select q.*, r.customer_company_id, r.currency as rfq_currency, r.id as rfq_id
    into v_quote
    from public.quotes q
    join public.rfqs r on r.id = q.rfq_id
   where q.id = p_quote_id
   for update;

  if not found then
    raise exception 'Quote % not found', p_quote_id;
  end if;

  if v_role <> 'admin' and v_quote.customer_company_id <> v_company then
    raise exception 'Quote % does not belong to your company', p_quote_id using errcode = '42501';
  end if;

  if v_quote.status <> 'submitted' then
    raise exception 'Quote % is not in submitted status', p_quote_id using errcode = '42809';
  end if;

  v_currency := coalesce(v_quote.currency, v_quote.rfq_currency);

  insert into public.orders (
    customer_company_id,
    created_by,
    status,
    notes,
    currency,
    subtotal,
    tax_total,
    total
  )
  values (
    v_quote.customer_company_id,
    v_user,
    'draft',
    coalesce(v_quote.terms->>'order_note', 'Created from accepted quote'),
    v_currency,
    0,
    0,
    0
  )
  returning id into v_order_id;

  for v_item in
    select qi.*, ri.variant_id as rfq_variant_id, ri.requested_uom
      from public.quote_items qi
      join public.rfq_items ri on ri.id = qi.rfq_item_id
     where qi.quote_id = v_quote.id
  loop
    v_variant := coalesce(v_item.offered_variant_id, v_item.rfq_variant_id);
    if v_variant is null then
      raise exception 'Quote item % is missing a variant_id', v_item.id using errcode = '23502';
    end if;

    v_tax := coalesce(v_item.tax_rate, 0);

    insert into public.order_items (
      order_id,
      vendor_company_id,
      variant_id,
      qty,
      uom,
      unit_price,
      discount_pct,
      tax_rate
    )
    values (
      v_order_id,
      v_quote.vendor_company_id,
      v_variant,
      v_item.qty,
      coalesce(v_item.uom, v_item.requested_uom, 'EA'),
      v_item.unit_price,
      0,
      v_tax
    );

    v_line_subtotal := v_item.unit_price * v_item.qty;
    v_subtotal := v_subtotal + v_line_subtotal;
    v_tax_total := v_tax_total + (v_line_subtotal * v_tax / 100);
  end loop;

  if v_subtotal = 0 then
    raise exception 'Accepted quote % must contain at least one item', p_quote_id using errcode = '22023';
  end if;

  update public.orders
     set subtotal = v_subtotal,
         tax_total = v_tax_total,
         total = v_subtotal + v_tax_total,
         updated_at = now()
   where id = v_order_id;

  update public.quotes
     set status = 'awarded',
         updated_at = now()
   where id = v_quote.id;

  update public.quotes
     set status = 'declined',
         updated_at = now()
   where rfq_id = v_quote.rfq_id
     and id <> v_quote.id
     and status in ('submitted','invited');

  update public.rfqs
     set status = 'awarded',
         meta = jsonb_set(meta, '{accepted_quote_id}', to_jsonb(v_quote.id), true),
         updated_at = now()
   where id = v_quote.rfq_id;

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'quote_awarded',
    'quotes',
    v_quote.id,
    jsonb_build_object(
      'order_id', v_order_id,
      'total', v_subtotal + v_tax_total
    )
  );

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'rfq_converted',
    'rfqs',
    v_quote.rfq_id,
    jsonb_build_object(
      'quote_id', v_quote.id,
      'order_id', v_order_id
    )
  );

  insert into public.audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    v_user,
    'order_created_from_quote',
    'orders',
    v_order_id,
    jsonb_build_object(
      'quote_id', v_quote.id,
      'total', v_subtotal + v_tax_total
    )
  );

  return v_order_id;
end;
$$;
grant execute on function public.rpc_customer_accept_quote(uuid) to authenticated;
