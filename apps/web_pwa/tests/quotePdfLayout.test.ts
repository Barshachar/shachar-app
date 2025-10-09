import { rgb } from 'pdf-lib';
import { describe, expect, test } from 'vitest';
import type { ColumnRect } from '@/app/api/quote/route';
import {
  buildSummaryEntries,
  NUMERIC_COLUMN_KEYS,
  TABLE_COLUMNS,
  formatCurrencyForPdf,
  formatInteger,
  formatQuantity,
  prepareSummaryRows,
  resolveTableRightEdge
} from '@/app/api/quote/route';
import type { QuoteTotals } from '@/lib/quote';

const RTL_START = '\u202B';
const RTL_END = '\u202C';
const DIRECTIONAL_MARK_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/;

describe('quote PDF layout', () => {
  test('defines table columns in RTL order', () => {
    const keys = TABLE_COLUMNS.map((column) => column.key);
    expect(keys).toEqual(['index', 'name', 'sku', 'qty', 'unit', 'total']);
  });

  test('numeric columns stay right aligned without extra wrapping', () => {
    for (const column of TABLE_COLUMNS) {
      if (NUMERIC_COLUMN_KEYS.has(column.key)) {
        expect(column.align).toBe('right');
        expect(column.wrapValue).toBe(false);
      }
    }
  });

  test('numeric column registry matches column definitions', () => {
    const numericColumnKeys = TABLE_COLUMNS.filter((column) =>
      NUMERIC_COLUMN_KEYS.has(column.key)
    ).map((column) => column.key);

    expect(numericColumnKeys).toEqual(['index', 'qty', 'unit', 'total']);
  });

  test('monospaced font restricted to index, sku, and quantity columns', () => {
    const monoColumns = TABLE_COLUMNS.filter((column) => column.useMono).map((column) => column.key);
    expect(monoColumns).toEqual(['index', 'sku', 'qty']);
  });

  test('formatCurrencyForPdf wraps sanitized amounts with RTL embedding', () => {
    const formatted = formatCurrencyForPdf(12345, 'subtotal');
    expect(formatted.startsWith(RTL_START)).toBe(true);
    expect(formatted.endsWith(RTL_END)).toBe(true);
    expect(formatted).toContain('₪');
    const payload = formatted.slice(1, -1);
    expect(DIRECTIONAL_MARK_REGEX.test(payload)).toBe(false);
  });

  test('formatCurrencyForPdf rejects non-integer cent values', () => {
    expect(() => formatCurrencyForPdf(199.5, 'invalid cents')).toThrow(
      /integer number of cents/
    );
  });

  test('formatCurrencyForPdf rejects unsafe integer cent values', () => {
    expect(() =>
      formatCurrencyForPdf(Number.MAX_SAFE_INTEGER + 1, 'unsafe cents')
    ).toThrow(/safe integer number of cents/);
  });

  test('formatInteger and formatQuantity sanitize numeric output', () => {
    const formattedIndex = formatInteger(42);
    expect(formattedIndex.includes(RTL_START)).toBe(false);
    expect(formattedIndex.includes(RTL_END)).toBe(false);
    expect(DIRECTIONAL_MARK_REGEX.test(formattedIndex)).toBe(false);

    const formattedQuantity = formatQuantity(12.345);
    expect(formattedQuantity.includes(RTL_START)).toBe(false);
    expect(formattedQuantity.includes(RTL_END)).toBe(false);
    expect(DIRECTIONAL_MARK_REGEX.test(formattedQuantity)).toBe(false);
  });

  test('resolveTableRightEdge respects column geometry when available', () => {
    const sampleColumn = TABLE_COLUMNS[0];
    const rects: ColumnRect[] = [
      {
        ...sampleColumn,
        left: 420,
        right: 420 + sampleColumn.width
      }
    ];

    expect(resolveTableRightEdge(rects, 595, 50)).toBe(rects[0].right);
  });

  test('resolveTableRightEdge falls back to page width minus margin', () => {
    const pageWidth = 612;
    const margin = 36;
    expect(resolveTableRightEdge([], pageWidth, margin)).toBe(pageWidth - margin);
  });

  test('resolveTableRightEdge validates fallback dimensions', () => {
    expect(() => resolveTableRightEdge([], 0, 50)).toThrow(/positive finite number/);
    expect(() => resolveTableRightEdge([], 612, -1)).toThrow(/non-negative/);
  });

  test('buildSummaryEntries returns ordered RTL summary rows', () => {
    const baseColor = rgb(0.1, 0.1, 0.1);
    const highlightColor = rgb(0.02, 0.4, 0.2);
    const totals: QuoteTotals = { subtotal: 1000, vat: 170, total: 1170 };

    const first = buildSummaryEntries(totals, 0.17, baseColor, highlightColor);
    const second = buildSummaryEntries(totals, 0.17, baseColor, highlightColor);

    expect(first.map((entry) => entry.key)).toEqual(['subtotal', 'vat', 'total']);
    expect(first[0]!.fontSize).toBe(12);
    expect(first[1]!.label).toContain('%');
    expect(DIRECTIONAL_MARK_REGEX.test(first[1]!.label)).toBe(false);
    expect(first[2]!.fontSize).toBe(14);
    expect(first[0]!.color).toBe(baseColor);
    expect(first[2]!.color).toBe(highlightColor);
    expect(second).not.toBe(first);
    expect(second).toEqual(first);
  });

  test('buildSummaryEntries enforces integer cents and VAT validation', () => {
    const baseColor = rgb(0.1, 0.1, 0.1);
    const highlightColor = rgb(0.02, 0.4, 0.2);

    expect(() =>
      buildSummaryEntries(
        { subtotal: 100.5, vat: 17, total: 117 } as QuoteTotals,
        0.17,
        baseColor,
        highlightColor
      )
    ).toThrow(/integer number of cents/);

    expect(() =>
      buildSummaryEntries(
        { subtotal: 100, vat: 17, total: 117 } as QuoteTotals,
        Number.NaN,
        baseColor,
        highlightColor
      )
    ).toThrow(/non-negative finite number/);

    expect(() =>
      buildSummaryEntries(
        { subtotal: 100, vat: 17, total: 117 } as QuoteTotals,
        -0.01,
        baseColor,
        highlightColor
      )
    ).toThrow(/non-negative finite number/);
  });

  test('buildSummaryEntries requires totals to equal subtotal plus VAT', () => {
    const baseColor = rgb(0.1, 0.1, 0.1);
    const highlightColor = rgb(0.02, 0.4, 0.2);

    expect(() =>
      buildSummaryEntries(
        { subtotal: 1000, vat: 170, total: 1169 } as QuoteTotals,
        0.17,
        baseColor,
        highlightColor
      )
    ).toThrow(/subtotal plus VAT/i);
  });

  test('summary entries convert cents to RTL ILS strings', () => {
    const baseColor = rgb(0.1, 0.1, 0.1);
    const highlightColor = rgb(0.02, 0.4, 0.2);
    const totals: QuoteTotals = { subtotal: 2500, vat: 425, total: 2925 };

    const entries = buildSummaryEntries(totals, 0.17, baseColor, highlightColor);
    for (const entry of entries) {
      const text = formatCurrencyForPdf(entry.cents, entry.key);
      expect(text.startsWith(RTL_START)).toBe(true);
      expect(text.endsWith(RTL_END)).toBe(true);
      const payload = text.slice(1, -1);
      expect(payload.includes('₪')).toBe(true);
      expect(DIRECTIONAL_MARK_REGEX.test(payload)).toBe(false);
    }
  });

  test('prepareSummaryRows returns wrapped labels and formatted amounts', () => {
    const totals: QuoteTotals = { subtotal: 12550, vat: 2134, total: 14684 };
    const rows = prepareSummaryRows(totals, 0.17);
    const expectedFields = {
      subtotal: 'summary subtotal',
      vat: 'summary VAT',
      total: 'summary total'
    } as const;

    expect(rows.map((row) => row.key)).toEqual(['subtotal', 'vat', 'total']);
    for (const row of rows) {
      expect(row.label.startsWith(RTL_START)).toBe(true);
      expect(row.label.endsWith(RTL_END)).toBe(true);
      expect(DIRECTIONAL_MARK_REGEX.test(row.label.slice(1, -1))).toBe(false);
      expect(row.value.startsWith(RTL_START)).toBe(true);
      expect(row.value.endsWith(RTL_END)).toBe(true);
      const expectedValue = formatCurrencyForPdf(
        totals[row.key],
        expectedFields[row.key]
      );
      expect(row.value).toBe(expectedValue);
      const valuePayload = row.value.slice(1, -1);
      expect(valuePayload.includes('₪')).toBe(true);
      expect(DIRECTIONAL_MARK_REGEX.test(valuePayload)).toBe(false);
    }
  });

  test('prepareSummaryRows validates VAT and integer totals', () => {
    const totals: QuoteTotals = { subtotal: 1000, vat: 170, total: 1170 };
    expect(() => prepareSummaryRows(totals, Number.NaN)).toThrow(/must be a finite number/);
    expect(() => prepareSummaryRows(totals, -0.01)).toThrow(/must be non-negative/);
    expect(() =>
      prepareSummaryRows({ subtotal: 1000, vat: 170, total: 1200 } as QuoteTotals, 0.17)
    ).toThrow(/must equal subtotal plus VAT/);
    expect(() =>
      prepareSummaryRows({ subtotal: 1000.5, vat: 170, total: 1170.5 } as QuoteTotals, 0.17)
    ).toThrow(/integer number of cents/);
  });
});
