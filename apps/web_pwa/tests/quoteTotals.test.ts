import { describe, expect, test } from 'vitest';
import { computeTotals } from '@/lib/quote';

describe('computeTotals', () => {
  test('returns zero totals for an empty collection', () => {
    const totals = computeTotals([], 0.17);
    expect(totals).toEqual({ subtotal: 0, vat: 0, total: 0 });
  });

  test('handles fractional quantities with rounding symmetry', () => {
    const items = [
      { qty: 1.5, unitPriceCents: 333 },
      { qty: 2.25, unitPriceCents: 799 }
    ] as const;

    const expectedSubtotal =
      Math.round(items[0]!.unitPriceCents * items[0]!.qty) +
      Math.round(items[1]!.unitPriceCents * items[1]!.qty);
    const expectedVat = Math.round(expectedSubtotal * 0.17);

    const totals = computeTotals(items, 0.17);
    expect(totals).toEqual({
      subtotal: expectedSubtotal,
      vat: expectedVat,
      total: expectedSubtotal + expectedVat
    });
  });

  test('applies VAT rounding consistently across edge cases', () => {
    const totals = computeTotals([{ qty: 1, unitPriceCents: 555 }], 0.17);
    expect(totals).toEqual({ subtotal: 555, vat: 94, total: 649 });
  });

  test('rejects invalid VAT rates and line inputs', () => {
    expect(() => computeTotals([{ qty: 1, unitPriceCents: 100 }], Number.NaN)).toThrow(
      /VAT rate must be a finite number/
    );
    expect(() => computeTotals([{ qty: 1, unitPriceCents: 100 }], -0.01)).toThrow(
      /VAT rate must be non-negative/
    );
    expect(() => computeTotals([{ qty: -1, unitPriceCents: 42 }], 0.17)).toThrow(
      /Item quantity must be non-negative/
    );
    expect(() => computeTotals([{ qty: 1, unitPriceCents: -42 }], 0.17)).toThrow(
      /Item price must be non-negative/
    );
    expect(() => computeTotals([{ qty: 1, unitPriceCents: 10.5 }], 0.17)).toThrow(
      /integer number of cents/
    );
  });
});
