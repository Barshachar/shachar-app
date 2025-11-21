import type { Database } from './supabase';

type DbPriceRow = Database['public']['Tables']['prices']['Row'];
type EffectivePriceRow = Database['public']['Views']['secure_effective_prices']['Row'];

const toCents = (value?: number | null): number => {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return 0;
  }
  return Math.round(value * 100);
};

export type PriceQuote = {
  variantId: string;
  priceListId?: string;
  vendorCompanyId?: string;
  currency?: string;
  minQty: number;
  unitPriceCents: number;
};

export function fromDbPriceRow(
  row: DbPriceRow,
  options?: { currency?: string; vendorCompanyId?: string }
): PriceQuote {
  return {
    variantId: row.variant_id,
    priceListId: row.price_list_id,
    vendorCompanyId: options?.vendorCompanyId,
    currency: options?.currency,
    minQty: row.min_qty ?? 1,
    unitPriceCents: toCents(row.unit_price)
  };
}

export function fromEffectivePriceRow(row: EffectivePriceRow): PriceQuote {
  if (!row.variant_id) {
    throw new Error('secure_effective_prices.variant_id is required to build a PriceQuote');
  }
  return {
    variantId: row.variant_id,
    vendorCompanyId: row.vendor_id ?? undefined,
    currency: row.currency ?? undefined,
    minQty: row.min_qty ?? 1,
    unitPriceCents: toCents(row.unit_price),
    priceListId: undefined
  };
}
