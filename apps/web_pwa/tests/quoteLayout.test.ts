import { describe, expect, test } from 'vitest';
import {
  NUMERIC_COLUMN_KEYS,
  TABLE_COLUMN_ORDER,
  TABLE_COLUMNS,
  buildSummaryTextEntries,
  computeColumnRectsForWidth,
  validateTableColumns
} from '@/app/api/quote/route';
import { formatILS } from '@/lib/formatter';
import { computeTotals, type QuoteTotals } from '@/lib/quote';
import { sanitizeNumberText } from '@/lib/pdf/rtl';

describe('quote PDF layout', () => {
  test('keeps RTL column order and numeric alignment', () => {
    expect(TABLE_COLUMN_ORDER).toEqual(['index', 'name', 'sku', 'qty', 'unit', 'total']);
    expect(() => validateTableColumns(TABLE_COLUMNS)).not.toThrow();

    for (const column of TABLE_COLUMNS) {
      if (NUMERIC_COLUMN_KEYS.has(column.key)) {
        expect(column.align).toBe('right');
        expect(column.wrapValue).toBe(false);
      }
    }

    const rects = computeColumnRectsForWidth(595, 50);
    expect(rects).toHaveLength(TABLE_COLUMNS.length);
    for (let index = 1; index < rects.length; index += 1) {
      const previous = rects[index - 1];
      const current = rects[index];
      expect(previous.left).toBe(current.right);
      expect(previous.right).toBeGreaterThan(current.right);
    }
  });

  test('wraps summary values with RTL markers and ILS formatting', () => {
    const totals = computeTotals(
      [
        { qty: 2, unitPriceCents: 1999 },
        { qty: 0.75, unitPriceCents: 3300 }
      ],
      0.17
    );

    const entries = buildSummaryTextEntries(totals, 0.17);
    expect(entries.map((entry) => entry.key)).toEqual(['subtotal', 'vat', 'total']);

    for (const entry of entries) {
      expect(entry.labelText.startsWith('\u202B')).toBe(true);
      expect(entry.labelText.endsWith('\u202C')).toBe(true);
      expect(entry.valueText.startsWith('\u202B')).toBe(true);
      expect(entry.valueText.endsWith('\u202C')).toBe(true);
      const innerValue = entry.valueText.slice(1, -1);
      expect(innerValue).toBe(sanitizeNumberText(formatILS(totals[entry.key])));
    }
  });

  test('rejects summary totals that are not integer cents', () => {
    const totals: QuoteTotals = {
      subtotal: 100.5,
      vat: 10,
      total: 110.5
    };

    expect(() => buildSummaryTextEntries(totals, 0.17)).toThrow(/integer number of cents/i);
  });
});
