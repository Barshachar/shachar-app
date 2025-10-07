import { NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { ensureCart, addCartItem } from '@/lib/cart-db';

export async function POST(request: Request) {
  const body = await request.json();
  const variantId = body.variant_id as string | undefined;
  const qty = Number(body.qty ?? 1);

  if (!variantId || Number.isNaN(qty) || qty <= 0) {
    return NextResponse.json({ error: 'variant_id ו-qty נדרשים' }, { status: 400 });
  }

  const sessionId = ensureSessionId();
  const cartId = await ensureCart(sessionId);
  await addCartItem({ cartId, variantId, qty });

  return NextResponse.json({ ok: true });
}
