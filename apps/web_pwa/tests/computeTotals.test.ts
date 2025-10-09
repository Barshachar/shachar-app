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

  test('requires unit prices to be whole cents', () => {
    expect(() =>
      computeTotals([{ qty: 1, unitPriceCents: 99.5 }], 0.17)
    ).toThrow(/integer number of cents/);
  });

  test('supports zero vat rate without mutating input', () => {
    const items = [
      { qty: 1.25, unitPriceCents: 4999 },
      { qty: 3, unitPriceCents: 2500 }
    ];
    const originalSnapshot = items.map((item) => ({ ...item }));

    const totals = computeTotals(items, 0);

    expect(totals).toEqual({
      subtotal: Math.round(1.25 * 4999) + Math.round(3 * 2500),
      vat: 0,
      total: Math.round(1.25 * 4999) + Math.round(3 * 2500)
    });
    expect(items).toEqual(originalSnapshot);
  });

  test('ignores zero-quantity lines while keeping rounding stable', () => {
    const items = [
      { qty: 0, unitPriceCents: 4400 },
      { qty: 2.5, unitPriceCents: 1999 }
    ];

    const totals = computeTotals(items, 0.17);

    const expectedSubtotal = Math.round(items[1].qty * items[1].unitPriceCents);
    const expectedVat = Math.round(expectedSubtotal * 0.17);

    expect(totals).toEqual({
      subtotal: expectedSubtotal,
      vat: expectedVat,
      total: expectedSubtotal + expectedVat
    });
  });

  test('rejects non-finite item quantities or prices', () => {
    expect(() =>
      computeTotals([{ qty: Number.POSITIVE_INFINITY, unitPriceCents: 100 }], 0.17)
    ).toThrow(/Item quantity must be a finite number/);
    expect(() =>
      computeTotals([{ qty: 1, unitPriceCents: Number.NaN }], 0.17)
    ).toThrow(/Item price must be a finite number/);
  });

  test('handles mixed precision lines and VAT rounding consistently', () => {
    const items = [
      { qty: 10.5, unitPriceCents: 199 },
      { qty: 3.333, unitPriceCents: 457 },
      { qty: 0.1, unitPriceCents: 1 }
    ];

    const totals = computeTotals(items, 0.165);

    const expectedSubtotal = items.reduce(
      (acc, item) => acc + Math.round(item.qty * item.unitPriceCents),
      0
    );
    const expectedVat = Math.round(expectedSubtotal * 0.165);
    const expectedTotal = expectedSubtotal + expectedVat;

    expect(totals).toEqual({
      subtotal: expectedSubtotal,
      vat: expectedVat,
      total: expectedTotal
    });
    expect(Number.isInteger(totals.subtotal)).toBe(true);
    expect(Number.isInteger(totals.vat)).toBe(true);
    expect(Number.isInteger(totals.total)).toBe(true);
  });

  test('keeps subtotal, vat, and total as integers with fractional VAT rates', () => {
    const totals = computeTotals([{ qty: 5.75, unitPriceCents: 2899 }], 0.165);
    expect(Number.isInteger(totals.subtotal)).toBe(true);
    expect(Number.isInteger(totals.vat)).toBe(true);
    expect(Number.isInteger(totals.total)).toBe(true);
  });

  test('is deterministic across repeated invocations with fractional quantities', () => {
    const items = [
      { qty: 2.5, unitPriceCents: 199 },
      { qty: 3.25, unitPriceCents: 501 },
      { qty: 0.05, unitPriceCents: 9999 }
    ];
    const vatRate = 0.17;

    const first = computeTotals(items, vatRate);
    const second = computeTotals(items, vatRate);

    expect(second).toEqual(first);
    expect(Number.isInteger(first.subtotal)).toBe(true);
    expect(Number.isInteger(first.vat)).toBe(true);
    expect(first.total).toBe(first.subtotal + first.vat);
  });

  test('handles large carts without accumulating rounding drift', () => {
    const items = Array.from({ length: 75 }, (_, index) => ({
      qty: 0.5 + (index % 4) * 0.25,
      unitPriceCents: 10_000 + index * 37
    }));
    const vatRate = 0.17;

    const expectedSubtotal = items.reduce(
      (acc, item) => acc + Math.round(item.qty * item.unitPriceCents),
      0
    );
    const expectedVat = Math.round(expectedSubtotal * vatRate);

    const totals = computeTotals(items, vatRate);

    expect(totals.subtotal).toBe(expectedSubtotal);
    expect(totals.vat).toBe(expectedVat);
    expect(totals.total).toBe(expectedSubtotal + expectedVat);
    expect(Number.isInteger(totals.total)).toBe(true);
  });
});
