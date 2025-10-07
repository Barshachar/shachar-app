import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';
import { computeVendorSplits } from './utils.ts';

serve(async (req) => {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  const payload = await req.json();
  const orderId = payload?.order_id as string | undefined;
  if (!orderId) {
    return errorResponse('order_id is required');
  }

  const supabase = getServiceClient();
  const { data: items, error } = await supabase
    .from('order_items')
    .select('vendor_company_id,line_total')
    .eq('order_id', orderId);

  if (error) {
    return errorResponse(error.message, 500);
  }

  const splits = computeVendorSplits((items ?? []) as any);

  for (const split of splits) {
    await supabase
      .from('shipments')
      .upsert({
        order_id: orderId,
        vendor_company_id: split.vendor_company_id,
        status: split.status,
        partial_flag: true,
      }, {
        onConflict: 'order_id,vendor_company_id',
      });
  }

  await supabase.functions.invoke('notify_status_change', {
    body: {
      order_id: orderId,
      event: 'order_split_updated',
    },
  });

  return jsonResponse({ order_id: orderId, vendors: splits });
});
