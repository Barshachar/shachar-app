import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { ensureCart, updateCartItem } from '@/lib/cart-db';

export async function POST(request: Request) {
  const body = await request.json();
  const itemId = body.item_id as string | undefined;
  const qty = Number(body.qty);

  if (!itemId || Number.isNaN(qty)) {
    return NextResponse.json({ error: 'item_id ו-qty נדרשים' }, { status: 400 });
  }

  const sessionId = ensureSessionId();
  const cartId = await ensureCart(sessionId);
  await updateCartItem({ cartId, itemId, qty });

  return NextResponse.json({ ok: true });
}
