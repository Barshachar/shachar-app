import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { ensureCart, removeCartItem } from '@/lib/cart-db';

export async function POST(request: Request) {
  const body = await request.json();
  const itemId = body.item_id as string | undefined;

  if (!itemId) {
    return NextResponse.json({ error: 'item_id נדרש' }, { status: 400 });
  }

  const sessionId = ensureSessionId();
  const cartId = await ensureCart(sessionId);
  await removeCartItem({ cartId, itemId });

  return NextResponse.json({ ok: true });
}
