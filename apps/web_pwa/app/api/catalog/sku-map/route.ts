import { NextResponse } from 'next/server';
import { shouldUseLocalData, getLocalProducts } from '@/lib/local-store';

export async function GET() {
  const items: { sku: string; variant_id: string; name: string }[] = [];

  if (shouldUseLocalData()) {
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
  }

  return NextResponse.json({ items });
}
