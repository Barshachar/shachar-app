set search_path = public, auth;

alter table orders
  add column if not exists cancelled_at timestamptz,
  add column if not exists cancelled_by uuid references auth.users(id),
  add column if not exists cancellation_reason text;

create index if not exists orders_cancelled_at_idx
  on orders(cancelled_at desc)
  where cancelled_at is not null;

create or replace function log_order_cancellation() returns trigger as $$
begin
  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (
    coalesce(auth.uid(), new.cancelled_by, new.created_by),
    'order_cancelled',
    'orders',
    new.id,
    jsonb_build_object(
      'order_id', new.id,
      'from', old.status,
      'reason', new.cancellation_reason,
      'cancelled_by', new.cancelled_by,
      'cancelled_at', new.cancelled_at
    )
  );

  return new;
end;
$$ language plpgsql security definer set search_path = public, auth;

drop trigger if exists orders_cancelled_audit on orders;
create trigger orders_cancelled_audit
  after update on orders
  for each row
  when (new.status = 'cancelled' and (old.status is distinct from new.status))
  execute function log_order_cancellation();
