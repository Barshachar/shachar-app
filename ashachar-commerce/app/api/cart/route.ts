import { NextRequest, NextResponse } from 'next/server';
import { ensureSessionId } from '@/lib/session';
import { fetchCartItems } from '@/lib/data';
import { computeCartTotal, type PriceMode } from '@/lib/pricing';

export async function GET(request: NextRequest) {
  const sessionId = ensureSessionId();
  const items = await fetchCartItems(sessionId);
  const mode = (request.nextUrl.searchParams.get('price_mode') as PriceMode) || 'b2c';
  const total_cents = computeCartTotal(
    items.map((item) => ({ variant: item.variant, qty: item.qty })),
    mode,
    null
  );

  return NextResponse.json({ items, total_cents, price_mode: mode });
}
