import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { ensureCart, clearCart } from '@/lib/cart-db';
import { assertLocalMode } from '@/lib/local-mode';

export async function POST() {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const sessionId = ensureSessionId();
  const cartId = await ensureCart(sessionId);
  await clearCart({ cartId });
  return NextResponse.json({ ok: true });
}
