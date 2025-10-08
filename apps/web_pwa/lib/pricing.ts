import type { ProductVariant } from '@/lib/types';

export type PriceMode = 'b2c' | 'b2b';

export type VariantPrice = {
  price_group: string;
  price_cents: number;
};

export type CartLine = {
  variant: ProductVariant;
  qty: number;
};

export function resolveVariantPrice(
  variant: ProductVariant,
  mode: PriceMode,
  priceGroup?: string | null
): number {
  if (mode === 'b2b' && priceGroup && variant.variant_prices) {
    const match = variant.variant_prices.find((price) => price.price_group === priceGroup);
    if (match) {
      return match.price_cents;
    }
  }
  return variant.price_cents;
}

export function resolveCartLineTotal(
  line: CartLine,
  mode: PriceMode,
  priceGroup?: string | null
): number {
  const price = resolveVariantPrice(line.variant, mode, priceGroup);
  return price * line.qty;
}

export function computeCartTotal(
  lines: CartLine[],
  mode: PriceMode,
  priceGroup?: string | null
): number {
  return lines.reduce((acc, line) => acc + resolveCartLineTotal(line, mode, priceGroup), 0);
}

export function computeDisplayPrice({
  variant,
  mode,
  priceGroup
}: {
  variant: ProductVariant;
  mode: PriceMode;
  priceGroup?: string | null;
}): { valueCents: number; isB2B: boolean } {
  const basePrice = variant.price_cents;
  const resolved = resolveVariantPrice(variant, mode, priceGroup);
  return {
    valueCents: resolved,
    isB2B: resolved !== basePrice
  };
}
