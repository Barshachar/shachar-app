import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { fetchCartItems, createOrUpdateOrder } from '@/lib/data';
import { computeCartTotal } from '@/lib/pricing';
import { buildCardcomRedirect } from '@/lib/cardcom';
import { assertLocalMode } from '@/lib/local-mode';

export async function POST() {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const sessionId = ensureSessionId();
  const items = await fetchCartItems(sessionId);

  if (!items.length) {
    return NextResponse.json({ error: 'העגלה ריקה' }, { status: 400 });
  }

  const totalCents = computeCartTotal(
    items.map((item) => ({ variant: item.variant, qty: item.qty })),
    'b2c'
  );

  const order = await createOrUpdateOrder({
    session_id: sessionId,
    total_cents: totalCents,
    status: 'pending'
  });

  const redirect = buildCardcomRedirect({
    sum: (totalCents / 100).toFixed(2),
    description: `Order ${order.id}`,
    orderId: order.id
  });

  return NextResponse.json({ redirect, order_id: order.id });
}
