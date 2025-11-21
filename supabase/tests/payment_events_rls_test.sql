\set ON_ERROR_STOP on

\set order_id 'A0000000-0000-0000-0000-000000000000'

-- Insert as admin (service role context assumed by CI DB)
insert into payment_events(provider, transaction_id, order_id)
values ('cardcom', 'trx-1', :'order_id');

-- Idempotency check: upsert same (provider, transaction_id) should not create duplicates
insert into payment_events(provider, transaction_id, order_id)
values ('cardcom', 'trx-1', :'order_id')
on conflict (provider, transaction_id) do nothing;

-- Expect exactly one row for trx-1
do $$
declare c int;
begin
  select count(*) into c from payment_events where provider='cardcom' and transaction_id='trx-1';
  if c <> 1 then
    raise exception 'idempotency failed: expected 1, got %', c;
  end if;
end$$;
