import type { Database } from './supabase';
type DbProductRow = Database['public']['Tables']['products']['Row'];
type DbVariantRow = Database['public']['Tables']['product_variants']['Row'];
type LocalizedName = {
    he?: string;
    en?: string;
};
export type ProductDto = {
    id: string;
    vendorCompanyId: string;
    categoryId: string | null;
    sku: string;
    uom: string;
    active: boolean;
    leadTimeDays?: number;
    moq?: number;
    packSize?: number;
    localizedName?: LocalizedName;
    attributes?: Record<string, unknown>;
};
export type ProductVariantDto = {
    id: string;
    productId: string;
    sku: string;
    uom: string;
    active: boolean;
    barcode?: string | null;
    attributes: Record<string, unknown>;
};
export declare function fromDbProductRow(row: DbProductRow): ProductDto;
export declare function fromDbVariantRow(row: DbVariantRow): ProductVariantDto;
export {};
//# sourceMappingURL=products.d.ts.map