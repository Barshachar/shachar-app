import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { ensureCart, clearCart } from '@/lib/cart-db';

export async function POST() {
  const sessionId = ensureSessionId();
  const cartId = await ensureCart(sessionId);
  await clearCart({ cartId });
  return NextResponse.json({ ok: true });
}
