import { describe, it, expect } from 'vitest';
import { fromDbProductRow, fromDbVariantRow } from './products';
import { fromDbPriceRow } from './pricing';
import { fromDbOrderRow } from './orders';
describe('contracts mappers', () => {
    it('maps product and variant rows', () => {
        const product = {
            id: 'p1',
            vendor_company_id: 'vendor-1',
            category_id: 'cat-1',
            sku: 'SKU-1',
            uom: 'unit',
            active: true,
            lead_time: 5,
            moq: 10,
            pack_size: 1,
            name: { he: 'שם', en: 'Name' },
            description: { material: 'copper' },
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        };
        const variant = {
            id: 'v1',
            product_id: 'p1',
            sku: 'SKU-1A',
            uom: 'unit',
            active: true,
            barcode: '123',
            attributes_json: { color: 'black' },
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        };
        const dto = fromDbProductRow(product);
        const variantDto = fromDbVariantRow(variant);
        expect(dto.vendorCompanyId).toBe('vendor-1');
        expect(dto.localizedName?.he).toBe('שם');
        expect(dto.attributes?.material).toBe('copper');
        expect(variantDto.attributes.color).toBe('black');
    });
    it('maps price rows with helpers', () => {
        const price = {
            id: 'price-1',
            price_list_id: 'pl-1',
            variant_id: 'v1',
            unit_price: 12.34,
            min_qty: 5,
            created_at: new Date().toISOString()
        };
        const quote = fromDbPriceRow(price, { currency: 'ILS' });
        expect(quote.unitPriceCents).toBe(1234);
        expect(quote.minQty).toBe(5);
        expect(quote.currency).toBe('ILS');
    });
    it('maps order rows and items', () => {
        const order = {
            id: 'o1',
            customer_company_id: 'comp-1',
            created_by: 'user-1',
            status: 'placed',
            currency: 'ILS',
            subtotal: 100,
            tax_total: 17,
            total: 117,
            notes: null,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            delivery_window: null,
            order_number: null
        };
        const item = {
            id: 'oi-1',
            order_id: 'o1',
            variant_id: 'v1',
            vendor_company_id: 'vendor-1',
            qty: 2,
            unit_price: 50,
            discount_pct: 0,
            tax_rate: 0.17,
            line_total: 100,
            uom: 'unit'
        };
        const dto = fromDbOrderRow(order, { items: [item] });
        expect(dto.totalCents).toBe(11700);
        expect(dto.items[0].unitPriceCents).toBe(5000);
    });
});
