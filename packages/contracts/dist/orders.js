const toCents = (value) => {
    if (typeof value !== 'number' || Number.isNaN(value)) {
        return 0;
    }
    return Math.round(value * 100);
};
export function fromDbOrderItemRow(row) {
    return {
        id: row.id,
        orderId: row.order_id,
        variantId: row.variant_id,
        vendorCompanyId: row.vendor_company_id,
        qty: row.qty,
        unitPriceCents: toCents(row.unit_price),
        discountPct: typeof row.discount_pct === 'number' ? row.discount_pct : undefined,
        taxRatePct: typeof row.tax_rate === 'number' ? row.tax_rate : undefined,
        lineTotalCents: typeof row.line_total === 'number' ? toCents(row.line_total) : undefined
    };
}
export function fromDbOrderRow(row, options) {
    const items = options?.items ?? [];
    return {
        id: row.id,
        companyId: row.customer_company_id,
        status: row.status,
        currency: row.currency,
        subtotalCents: toCents(row.subtotal),
        taxCents: toCents(row.tax_total),
        totalCents: toCents(row.total),
        notes: row.notes,
        createdAt: row.created_at,
        updatedAt: row.updated_at,
        createdBy: row.created_by,
        deliveryWindow: row.delivery_window ?? undefined,
        items: items.map(fromDbOrderItemRow)
    };
}
