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

  test('supports zero VAT and preserves integer cents', () => {
    const items = [
      { qty: 1, unitPriceCents: 10005 },
      { qty: 2.5, unitPriceCents: 330 }
    ] as const;
    const expectedSubtotal =
      Math.round(items[0].unitPriceCents * items[0].qty) +
      Math.round(items[1].unitPriceCents * items[1].qty);

    const totals = computeTotals(items, 0);
    expect(totals).toEqual({
      subtotal: expectedSubtotal,
      vat: 0,
      total: expectedSubtotal
    });
    expect(Number.isInteger(totals.subtotal)).toBe(true);
    expect(Number.isInteger(totals.total)).toBe(true);
  });

  test('does not mutate input items and keeps rounding stable', () => {
    const items = [
      { qty: 1.75, unitPriceCents: 2222 },
      { qty: 3, unitPriceCents: 405 }
    ];
    const snapshot = items.map((item) => ({ ...item }));

    const totals = computeTotals(items, 0.19);

    expect(items).toEqual(snapshot);
    const expectedSubtotal =
      Math.round(snapshot[0].qty * snapshot[0].unitPriceCents) +
      Math.round(snapshot[1].qty * snapshot[1].unitPriceCents);
    const expectedVat = Math.round(expectedSubtotal * 0.19);
    expect(totals.subtotal).toBe(expectedSubtotal);
    expect(totals.vat).toBe(expectedVat);
    expect(totals.total).toBe(expectedSubtotal + expectedVat);
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

  test('throws when item data is not finite', () => {
    expect(() =>
      computeTotals([{ qty: Number.POSITIVE_INFINITY, unitPriceCents: 100 }], 0.17)
    ).toThrow(/Item quantity must be a finite number/);
    expect(() =>
      computeTotals([{ qty: 1, unitPriceCents: Number.NEGATIVE_INFINITY }], 0.17)
    ).toThrow(/Item price must be a finite number/);
  });

  test('keeps integer cents for high precision quantities', () => {
    const items = [
      { qty: 0.333, unitPriceCents: 19999 },
      { qty: 2.667, unitPriceCents: 501 },
      { qty: 1.5, unitPriceCents: 0 }
    ];
    const totals = computeTotals(items, 0.17);
    const expectedSubtotal = items.reduce(
      (acc, item) => acc + Math.round(item.qty * item.unitPriceCents),
      0
    );

    expect(totals.subtotal).toBe(expectedSubtotal);
    expect(Number.isInteger(totals.vat)).toBe(true);
    expect(Number.isInteger(totals.total)).toBe(true);
  });
});
