import { describe, expect, test } from 'vitest';
import {
  TABLE_COLUMNS,
  computeColumnRectsForWidth,
  formatCurrencyForPdf
} from '@/app/api/quote/route';

const DIRECTIONAL_MARKS_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g;

describe('quote PDF layout helpers', () => {
  test('TABLE_COLUMNS keeps RTL order and numeric alignment', () => {
    expect(TABLE_COLUMNS.map((column) => column.key)).toEqual([
      'index',
      'name',
      'sku',
      'qty',
      'unit',
      'total'
    ]);

    const numericKeys = new Set(['index', 'qty', 'unit', 'total']);
    for (const column of TABLE_COLUMNS) {
      if (numericKeys.has(column.key)) {
        expect(column.align).toBe('right');
      }
    }
  });

  const totalWidth = TABLE_COLUMNS.reduce((sum, column) => sum + column.width, 0);

  test('computeColumnRectsForWidth anchors the table to the right margin', () => {
    const pageWidth = 595;
    const margin = 50;
    const rects = computeColumnRectsForWidth(pageWidth, margin);
    const idealRight = Math.max(pageWidth - margin, 0);
    const expectedLeft = Math.max(0, idealRight - totalWidth);
    const expectedRight = Math.min(expectedLeft + totalWidth, idealRight);

    expect(rects.map((rect) => rect.key)).toEqual(
      TABLE_COLUMNS.map((column) => column.key)
    );
    expect(rects[0]?.right).toBe(expectedRight);
    expect(rects.at(-1)?.left).toBe(expectedLeft);
    rects.forEach((rect, index) => {
      if (index > 0) {
        expect(rect.right).toBe(rects[index - 1]?.left);
      }
      expect(rect.left).toBeGreaterThanOrEqual(expectedLeft);
      expect(rect.right).toBeLessThanOrEqual(expectedRight);
    });
  });

  test('computeColumnRectsForWidth clamps narrow pages instead of overflowing', () => {
    const pageWidth = 360;
    const margin = 24;
    const rects = computeColumnRectsForWidth(pageWidth, margin);
    const idealRight = Math.max(pageWidth - margin, 0);
    const expectedLeft = Math.max(0, idealRight - totalWidth);
    const expectedRight = Math.min(expectedLeft + totalWidth, idealRight);

    expect(rects[0]?.right).toBe(expectedRight);
    expect(rects.at(-1)?.left).toBe(expectedLeft);
    rects.forEach((rect) => {
      expect(rect.left).toBeGreaterThanOrEqual(expectedLeft);
      expect(rect.right).toBeLessThanOrEqual(expectedRight);
    });
  });

  test('computeColumnRectsForWidth validates inputs', () => {
    expect(() => computeColumnRectsForWidth(0, 50)).toThrow(/pageWidth/);
    expect(() => computeColumnRectsForWidth(612, -1)).toThrow(/margin/);
  });

  test('formatCurrencyForPdf wraps sanitized RTL currency strings', () => {
    const formatted = formatCurrencyForPdf(12345, 'subtotal');
    expect(formatted.startsWith('\u202B')).toBe(true);
    expect(formatted.endsWith('\u202C')).toBe(true);
    expect(formatted.slice(1, -1)).not.toMatch(DIRECTIONAL_MARKS_REGEX);
  });

  test('formatCurrencyForPdf rejects non-integer cents', () => {
    expect(() => formatCurrencyForPdf(101.5, 'unit price')).toThrow(
      /integer number of cents/
    );
  });
});
