function toRecord(value) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) {
        return undefined;
    }
    return value;
}
function toLocalizedName(value) {
    const record = toRecord(value);
    if (!record) {
        return undefined;
    }
    const translated = {};
    if (typeof record.he === 'string') {
        translated.he = record.he;
    }
    if (typeof record.en === 'string') {
        translated.en = record.en;
    }
    return Object.keys(translated).length ? translated : undefined;
}
export function fromDbProductRow(row) {
    return {
        id: row.id,
        vendorCompanyId: row.vendor_company_id,
        categoryId: row.category_id,
        sku: row.sku,
        uom: row.uom,
        active: row.active,
        leadTimeDays: typeof row.lead_time === 'number' ? row.lead_time : undefined,
        moq: typeof row.moq === 'number' ? row.moq : undefined,
        packSize: typeof row.pack_size === 'number' ? row.pack_size : undefined,
        localizedName: toLocalizedName(row.name),
        attributes: toRecord(row.description)
    };
}
export function fromDbVariantRow(row) {
    return {
        id: row.id,
        productId: row.product_id,
        sku: row.sku,
        uom: row.uom,
        active: row.active,
        barcode: row.barcode,
        attributes: toRecord(row.attributes_json) ?? {}
    };
}
