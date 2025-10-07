begin;

create or replace view public.v_admin_orders as
with vendor_breakdown as (
  select
    oi.order_id,
    oi.vendor_company_id,
    vc.name as vendor_name,
    count(*)::int as items_count,
    sum(oi.unit_price * oi.qty) as subtotal,
    sum((oi.unit_price * oi.qty) * (oi.tax_rate / 100)) as tax_total,
    sum(oi.line_total) as total
  from public.order_items oi
  join public.companies vc on vc.id = oi.vendor_company_id
  group by oi.order_id, oi.vendor_company_id, vc.name
), vendor_agg as (
  select
    order_id,
    jsonb_agg(
      jsonb_build_object(
        'vendor_company_id', vendor_company_id,
        'vendor_name', vendor_name,
        'items_count', items_count,
        'subtotal', subtotal,
        'tax_total', tax_total,
        'total', total
      )
      order by vendor_name
    ) as vendor_summaries,
    count(*) as vendor_count
  from vendor_breakdown
  group by order_id
), shipment_agg as (
  select order_id, count(*) as shipment_count
  from public.shipments
  group by order_id
)
select
  o.id,
  o.order_number,
  o.status,
  o.created_at,
  o.updated_at,
  o.customer_company_id,
  cust.name as customer_name,
  o.subtotal,
  o.tax_total,
  o.total,
  coalesce(va.vendor_count, 0) as vendor_count,
  coalesce(sa.shipment_count, 0) as shipment_count,
  coalesce(va.vendor_summaries, '[]'::jsonb) as vendor_summaries
from public.orders o
left join public.companies cust on cust.id = o.customer_company_id
left join vendor_agg va on va.order_id = o.id
left join shipment_agg sa on sa.order_id = o.id;

comment on view public.v_admin_orders is 'Administrative order listing with vendor and shipment aggregates';

grant select on public.v_admin_orders to authenticated, service_role;

create index if not exists orders_status_idx on public.orders(status);
create index if not exists shipments_order_idx on public.shipments(order_id);
create index if not exists order_items_order_vendor_idx on public.order_items(order_id, vendor_company_id);

commit;
