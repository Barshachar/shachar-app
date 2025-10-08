import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

type NotificationRequest = {
  order_id: string;
  event: string;
  recipients?: string[];
  message?: string;
};

serve(async (req) => {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  const payload = (await req.json()) as NotificationRequest;
  if (!payload.order_id || !payload.event) {
    return errorResponse('order_id and event required');
  }

  const supabase = getServiceClient();
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .select('id, order_number, customer_company_id')
    .eq('id', payload.order_id)
    .single();

  if (orderError || !order) {
    return errorResponse(orderError?.message ?? 'Order not found', 404);
  }

  const { data: users, error: userError } = await supabase
    .rpc('list_order_recipients', { p_order_id: payload.order_id });

  if (userError) {
    return errorResponse(userError.message, 500);
  }

  const notifications = (users ?? []).map((recipient: { user_id: string }) => ({
    user_id: recipient.user_id,
    title: `Order ${order.order_number} ${payload.event}`,
    body: payload.message ?? `Order ${order.order_number} changed status to ${payload.event}`,
    data: { order_id: payload.order_id, event: payload.event },
  }));

  if (notifications.length > 0) {
    await supabase.from('notifications').insert(notifications);
  }

  return jsonResponse({
    order_id: payload.order_id,
    dispatched: notifications.length,
  });
});
