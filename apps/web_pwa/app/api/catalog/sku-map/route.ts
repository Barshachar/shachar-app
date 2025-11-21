import { NextResponse } from 'next/server';
import { getLocalProducts } from '@/lib/local-store';
import { assertLocalMode } from '@/lib/local-mode';

export async function GET() {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const items: { sku: string; variant_id: string; name: string }[] = [];

  const products = await getLocalProducts();
  for (const product of products) {
    for (const variant of product.variants) {
      if (!variant.sku) {
        continue;
      }
      items.push({
        sku: variant.sku,
        variant_id: variant.id,
        name: product.name
      });
    }
  }

  return NextResponse.json({ items });
}
