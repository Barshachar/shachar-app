import type { Database } from './supabase';
type DbOrderRow = Database['public']['Tables']['orders']['Row'];
type DbOrderItemRow = Database['public']['Tables']['order_items']['Row'];
export type OrderItemDto = {
    id: string;
    orderId: string;
    variantId: string;
    vendorCompanyId: string;
    qty: number;
    unitPriceCents: number;
    discountPct?: number;
    taxRatePct?: number;
    lineTotalCents?: number;
};
export type OrderDto = {
    id: string;
    companyId: string;
    status: DbOrderRow['status'];
    currency: string;
    subtotalCents: number;
    taxCents: number;
    totalCents: number;
    notes?: string | null;
    createdAt: string;
    updatedAt: string;
    createdBy: string;
    deliveryWindow?: DbOrderRow['delivery_window'];
    items: OrderItemDto[];
};
export declare function fromDbOrderItemRow(row: DbOrderItemRow): OrderItemDto;
export declare function fromDbOrderRow(row: DbOrderRow, options?: {
    items?: DbOrderItemRow[];
}): OrderDto;
export {};
//# sourceMappingURL=orders.d.ts.map