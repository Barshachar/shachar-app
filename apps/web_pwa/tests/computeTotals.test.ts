import { describe, expect, test } from 'vitest';
import { computeTotals } from '@/lib/quote';

describe('computeTotals', () => {
  test('calculates subtotal, vat, and total for basic lines', () => {
    const totals = computeTotals(
      [
        { qty: 2, unitPriceCents: 12900 },
        { qty: 1, unitPriceCents: 5500 }
      ],
      0.17
    );

    expect(totals).toEqual({
      subtotal: 31300,
      vat: 5321,
      total: 36621
    });
  });

  test('returns zeros for empty items', () => {
    const totals = computeTotals([], 0.17);
    expect(totals).toEqual({
      subtotal: 0,
      vat: 0,
      total: 0
    });
  });

  test('handles fractional quantities with rounding', () => {
    const totals = computeTotals(
      [{ qty: 1.333, unitPriceCents: 9999 }],
      0.17
    );

    const expectedSubtotal = Math.round(9999 * 1.333);
    expect(totals.subtotal).toBe(expectedSubtotal);
    expect(totals.vat).toBe(Math.round(totals.subtotal * 0.17));
    expect(totals.total).toBe(totals.subtotal + totals.vat);
  });

  test('rounds VAT cents correctly', () => {
    const totals = computeTotals([{ qty: 1, unitPriceCents: 333 }], 0.17);
    expect(totals.vat).toBe(57);
    expect(totals.total).toBe(390);
  });

  test('handles large totals without losing precision', () => {
    const totals = computeTotals(
      [
        { qty: 1200, unitPriceCents: 98765 },
        { qty: 850.5, unitPriceCents: 43210 }
      ],
      0.17
    );

    const expectedSubtotal =
      Math.round(1200 * 98765) + Math.round(850.5 * 43210);
    expect(totals.subtotal).toBe(expectedSubtotal);
    expect(Number.isInteger(totals.subtotal)).toBe(true);
    expect(Number.isInteger(totals.vat)).toBe(true);
    expect(Number.isInteger(totals.total)).toBe(true);
  });

  test('does not mutate the provided items array', () => {
    const items = [
      { qty: 1.5, unitPriceCents: 1000 },
      { qty: 2, unitPriceCents: 2500 }
    ];
    const snapshot = items.map((item) => ({ ...item }));

    computeTotals(items, 0.17);

    expect(items).toEqual(snapshot);
  });

  test('throws when vat rate is invalid', () => {
    expect(() => computeTotals([{ qty: 1, unitPriceCents: 100 }], Number.NaN)).toThrow(
      /VAT rate must be a finite number/
    );
    expect(() => computeTotals([{ qty: 1, unitPriceCents: 100 }], -0.1)).toThrow(
      /VAT rate must be non-negative/
    );
  });

  test('throws when item data is invalid', () => {
    expect(() =>
      computeTotals([{ qty: -1, unitPriceCents: 100 }], 0.17)
    ).toThrow(/Item quantity must be non-negative/);
    expect(() =>
      computeTotals([{ qty: 1, unitPriceCents: -50 }], 0.17)
    ).toThrow(/Item price must be non-negative/);
  });
});
