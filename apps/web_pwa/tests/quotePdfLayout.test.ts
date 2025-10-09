import { describe, expect, test } from 'vitest';
import type { PDFFont } from 'pdf-lib';
import {
  TABLE_COLUMNS,
  NUMERIC_COLUMN_KEYS,
  computeColumnRectsForWidth,
  formatCurrencyForPdf,
  resolveColumnTextX
} from '@/app/api/quote/route';
import { stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';

const DIRECTIONAL_MARKS_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g;

describe('quote PDF RTL layout helpers', () => {
  test('TABLE_COLUMNS preserves expected RTL ordering', () => {
    const keys = TABLE_COLUMNS.map((column) => column.key);
    expect(keys).toEqual(['index', 'name', 'sku', 'qty', 'unit', 'total']);
  });

  test('numeric columns stay right-aligned with appropriate fonts', () => {
    for (const column of TABLE_COLUMNS) {
      if (NUMERIC_COLUMN_KEYS.has(column.key)) {
        expect(column.align).toBe('right');
        expect(column.wrapValue).toBe(false);
      }
    }

    const indexColumn = TABLE_COLUMNS.find((column) => column.key === 'index');
    const qtyColumn = TABLE_COLUMNS.find((column) => column.key === 'qty');
    const unitColumn = TABLE_COLUMNS.find((column) => column.key === 'unit');
    const totalColumn = TABLE_COLUMNS.find((column) => column.key === 'total');

    expect(indexColumn?.useMono).toBe(true);
    expect(qtyColumn?.useMono).toBe(true);
    expect(unitColumn?.useMono).toBe(false);
    expect(totalColumn?.useMono).toBe(false);
  });

  test('computeColumnRectsForWidth anchors columns consistently', () => {
    const pageWidth = 595;
    const margin = 50;
    const rects = computeColumnRectsForWidth(pageWidth, margin);
    const totalWidth = TABLE_COLUMNS.reduce((sum, column) => sum + column.width, 0);
    const idealRight = Math.max(pageWidth - margin, 0);
    const expectedLeft = Math.max(0, idealRight - totalWidth);
    const expectedRight = expectedLeft + totalWidth;

    expect(rects.map((rect) => rect.key)).toEqual(
      TABLE_COLUMNS.map((column) => column.key)
    );
    expect(rects[0]?.right).toBe(expectedRight);
    expect(rects.at(-1)?.left).toBe(expectedLeft);
    rects.forEach((rect) => {
      expect(rect.right).toBeLessThanOrEqual(expectedRight);
      expect(rect.left).toBeGreaterThanOrEqual(expectedLeft);
    });
  });

  test('computeColumnRectsForWidth handles narrow pages gracefully', () => {
    const pageWidth = 360;
    const margin = 24;
    const rects = computeColumnRectsForWidth(pageWidth, margin);
    const totalWidth = TABLE_COLUMNS.reduce((sum, column) => sum + column.width, 0);
    const idealRight = Math.max(pageWidth - margin, 0);
    const expectedLeft = Math.max(0, idealRight - totalWidth);
    const expectedRight = expectedLeft + totalWidth;

    expect(rects[0]?.right).toBe(expectedRight);
    expect(rects.at(-1)?.left).toBe(expectedLeft);
  });

  test('computeColumnRectsForWidth validates inputs', () => {
    expect(() => computeColumnRectsForWidth(0, 50)).toThrow(/positive finite number/);
    expect(() => computeColumnRectsForWidth(612, -1)).toThrow(/non-negative/);
  });

  test('formatCurrencyForPdf wraps and sanitizes currency', () => {
    const formatted = formatCurrencyForPdf(12345, 'subtotal');
    expect(formatted.startsWith('\u202B')).toBe(true);
    expect(formatted.endsWith('\u202C')).toBe(true);
    const inner = formatted.slice(1, -1);
    expect(inner).toContain('₪');
    expect(inner).not.toMatch(DIRECTIONAL_MARKS_REGEX);
  });

  test('formatCurrencyForPdf rejects non-integer cents', () => {
    expect(() => formatCurrencyForPdf(101.5, 'unit price')).toThrow(/integer number of cents/);
  });

  test('resolveColumnTextX respects column alignment semantics', () => {
    const fakeFont = {
      widthOfTextAtSize(text: string, size: number) {
        return text.length * (size / 2);
      }
    } as unknown as PDFFont;

    const rtlText = wrapRtl('123456');
    const sanitizedWidth =
      stripDirectionalMarkers(rtlText).length * (10 / 2);

    const rightAlignedColumn = { align: 'right', left: 80, right: 160 } as const;
    const rightX = resolveColumnTextX(rightAlignedColumn, rtlText, fakeFont, 10);

    expect(rightX).toBeCloseTo(rightAlignedColumn.right - sanitizedWidth, 5);
    expect(rightX).toBeGreaterThanOrEqual(rightAlignedColumn.left);

    const leftAlignedColumn = { align: 'left', left: 220, right: 280 } as const;
    const leftX = resolveColumnTextX(leftAlignedColumn, rtlText, fakeFont, 10);

    expect(leftX).toBe(leftAlignedColumn.left);
  });
});
