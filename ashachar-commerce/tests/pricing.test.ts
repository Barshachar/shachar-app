import { computeCartTotal, computeDisplayPrice } from '@/lib/pricing';
import type { ProductVariant } from '@/lib/types';

const VARIANT: ProductVariant = {
  id: 'variant',
  name: 'Basic',
  sku: 'SKU-1',
  price_cents: 1000,
  currency: 'ILS',
  barcode: null,
  variant_prices: [
    { price_group: 'installer', price_cents: 800 }
  ]
};

describe('pricing helpers', () => {
  it('computes cart totals for b2c', () => {
    const total = computeCartTotal([{ variant: VARIANT, qty: 2 }], 'b2c');
    expect(total).toBe(2000);
  });

  it('applies variant price group for b2b', () => {
    const { valueCents, isB2B } = computeDisplayPrice({ variant: VARIANT, mode: 'b2b', priceGroup: 'installer' });
    expect(valueCents).toBe(800);
    expect(isB2B).toBe(true);
  });
});
