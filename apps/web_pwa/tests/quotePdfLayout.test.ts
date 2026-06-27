import { describe, expect, test } from 'vitest';
import type { PDFFont } from 'pdf-lib';
import {
  TABLE_COLUMNS,
  NUMERIC_COLUMN_KEYS,
  computeColumnRectsForWidth,
  formatCurrencyForPdf,
  normalizeRtlTableValue,
  resolveColumnTextX,
  resolveTableRightEdge,
  buildSummaryTextEntries,
  validateTableColumns
} from '@/app/api/quote/pdf-helpers';
import type { ColumnRect } from '@/app/api/quote/pdf-helpers';
import { stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';
import { formatILS } from '@/lib/formatter';
import type { QuoteTotals } from '@/lib/quote';

const DIRECTIONAL_MARKS_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g;
const RTL_START = '\u202B';
const RTL_END = '\u202C';
type ColumnDefinition = (typeof TABLE_COLUMNS)[number];

describe('quote PDF RTL layout helpers', () => {
  test('normalizeRtlTableValue trims text, strips directional marks, and falls back safely', () => {
    const raw = '\u200F  מוצר איכותי \u202C';
    expect(normalizeRtlTableValue(raw)).toBe('מוצר איכותי');

    const onlyMarkers = '\u202E\u200F';
    expect(normalizeRtlTableValue(onlyMarkers)).toBe('—');

    expect(normalizeRtlTableValue(undefined, 'N/A')).toBe('N/A');
  });

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

  test('formatCurrencyForPdf rejects unsafe integer cent magnitudes', () => {
    expect(() =>
      formatCurrencyForPdf(Number.MAX_SAFE_INTEGER + 1, 'unsafe cents')
    ).toThrow(/safe integer number of cents/);
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

  test('validateTableColumns enforces order and numeric alignment', () => {
    expect(() => validateTableColumns(TABLE_COLUMNS)).not.toThrow();

    const misordered: ColumnDefinition[] = Array.from(TABLE_COLUMNS).reverse();
    expect(() => validateTableColumns(misordered)).toThrow(/RTL column order/);

    const misaligned: ColumnDefinition[] = Array.from(TABLE_COLUMNS, (column) =>
      column.key === 'unit' ? { ...column, align: 'left' as const } : column
    );
    expect(() => validateTableColumns(misaligned)).toThrow(/right-aligned/);

    const wrappedNumeric: ColumnDefinition[] = Array.from(TABLE_COLUMNS, (column) =>
      column.key === 'total' ? { ...column, wrapValue: true } : column
    );
    expect(() => validateTableColumns(wrappedNumeric)).toThrow(/wrap values/);
  });

  test('resolveTableRightEdge uses column geometry when available', () => {
    const sampleColumn = TABLE_COLUMNS[0];
    const rects: ColumnRect[] = [
      {
        ...sampleColumn,
        left: 420,
        right: 420 + sampleColumn.width
      }
    ];

    expect(resolveTableRightEdge(rects, 595, 50)).toBe(rects[0]!.right);
  });

  test('resolveTableRightEdge handles empty geometry safely', () => {
    const pageWidth = 612;
    const margin = 36;
    expect(resolveTableRightEdge([], pageWidth, margin)).toBe(pageWidth - margin);
  });

  test('resolveTableRightEdge validates fallback inputs', () => {
    expect(() => resolveTableRightEdge([], 0, 50)).toThrow(/positive finite number/);
    expect(() => resolveTableRightEdge([], 612, -1)).toThrow(/non-negative/);
  });

  test('buildSummaryTextEntries produces wrapped and sanitized output', () => {
    const totals: QuoteTotals = { subtotal: 31300, vat: 5321, total: 36621 };
    const entries = buildSummaryTextEntries(totals, 0.17);

    expect(entries.map((entry) => entry.key)).toEqual(['subtotal', 'vat', 'total']);
    for (const entry of entries) {
      expect(entry.labelText.startsWith(RTL_START)).toBe(true);
      expect(entry.labelText.endsWith(RTL_END)).toBe(true);
      expect(entry.valueText.startsWith(RTL_START)).toBe(true);
      expect(entry.valueText.endsWith(RTL_END)).toBe(true);
      const payload = entry.valueText.slice(1, -1);
      expect(payload).toContain('₪');
      expect(DIRECTIONAL_MARKS_REGEX.test(payload)).toBe(false);
    }

    const vatEntry = entries.find((entry) => entry.key === 'vat');
    expect(vatEntry?.labelText.slice(1, -1)).toContain('17');

    const totalEntry = entries.find((entry) => entry.key === 'total');
    expect(totalEntry?.valueText).toBe(`${RTL_START}${formatILS(totals.total)}${RTL_END}`);
    expect(totalEntry?.fontSize).toBe(14);
  });

  test('buildSummaryTextEntries enforces integer cents and VAT validation', () => {
    const invalidTotals = {
      subtotal: 101.5,
      vat: 17,
      total: 118.5
    } as unknown as QuoteTotals;
    expect(() => buildSummaryTextEntries(invalidTotals, 0.17)).toThrow(/integer number of cents/);

    const zeroTotals: QuoteTotals = { subtotal: 0, vat: 0, total: 0 };
    expect(() => buildSummaryTextEntries(zeroTotals, Number.NaN)).toThrow(/finite number/);
    expect(() => buildSummaryTextEntries(zeroTotals, -0.1)).toThrow(/non-negative/);

    const mismatchedTotals: QuoteTotals = { subtotal: 1000, vat: 170, total: 1169 };
    expect(() => buildSummaryTextEntries(mismatchedTotals, 0.17)).toThrow(/subtotal plus VAT/);
  });
});
