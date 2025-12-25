set search_path = public, auth, extensions;

do $$
begin
  if not exists (
    select 1 from pg_type where typname = 'return_status'
  ) then
    create type return_status as enum (
      'requested',
      'approved',
      'rejected',
      'received',
      'refunded'
    );
  end if;
end;
$$;

alter table returns
  add column if not exists status return_status not null default 'requested',
  add column if not exists created_by uuid references auth.users(id),
  add column if not exists resolved_by uuid references auth.users(id),
  add column if not exists resolution_note text,
  add column if not exists resolved_at timestamptz,
  add column if not exists updated_at timestamptz not null default now();

update returns r
   set created_by = o.created_by
  from orders o
 where r.created_by is null
   and r.order_id = o.id;

alter table returns alter column created_by set not null;

do $$
begin
  if not exists (
    select 1
      from pg_constraint
     where conname = 'returns_qty_positive'
  ) then
    alter table returns
      add constraint returns_qty_positive check (qty > 0);
  end if;
end;
$$;

create index if not exists returns_order_idx on returns(order_id);
create index if not exists returns_item_idx on returns(item_id);
create index if not exists returns_status_idx on returns(status);

create or replace function log_return_audit() returns trigger as $$
begin
  if tg_op = 'INSERT' then
    insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
    values (
      coalesce(auth.uid(), new.resolved_by, new.created_by),
      'return_requested',
      'returns',
      new.id,
      jsonb_build_object(
        'order_id',
        new.order_id,
        'item_id',
        new.item_id,
        'qty',
        new.qty,
        'status',
        new.status
      )
    );
  elsif tg_op = 'UPDATE' and new.status is distinct from old.status then
    insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
    values (
      coalesce(auth.uid(), new.resolved_by, new.created_by),
      'return_status_updated',
      'returns',
      new.id,
      jsonb_build_object(
        'order_id',
        new.order_id,
        'item_id',
        new.item_id,
        'from',
        old.status,
        'to',
        new.status
      )
    );
  end if;

  return new;
end;
$$ language plpgsql security definer set search_path = public, auth;

drop trigger if exists returns_audit_log on returns;
create trigger returns_audit_log
  after insert or update on returns
  for each row execute function log_return_audit();
