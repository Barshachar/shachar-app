import type { Database } from './supabase';
type DbPriceRow = Database['public']['Tables']['prices']['Row'];
type EffectivePriceRow = Database['public']['Views']['secure_effective_prices']['Row'];
export type PriceQuote = {
    variantId: string;
    priceListId?: string;
    vendorCompanyId?: string;
    currency?: string;
    minQty: number;
    unitPriceCents: number;
};
export declare function fromDbPriceRow(row: DbPriceRow, options?: {
    currency?: string;
    vendorCompanyId?: string;
}): PriceQuote;
export declare function fromEffectivePriceRow(row: EffectivePriceRow): PriceQuote;
export {};
//# sourceMappingURL=pricing.d.ts.map