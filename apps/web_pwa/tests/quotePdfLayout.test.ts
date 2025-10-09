import { describe, expect, test } from 'vitest';
import { TABLE_COLUMNS, formatCurrencyForPdf } from '@/app/api/quote/route';

const RTL_START = '\u202B';
const RTL_END = '\u202C';
const DIRECTIONAL_MARK_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/;

describe('quote PDF layout', () => {
  test('defines table columns in RTL order', () => {
    const keys = TABLE_COLUMNS.map((column) => column.key);
    expect(keys).toEqual(['index', 'name', 'sku', 'qty', 'unit', 'total']);
  });

  test('numeric columns stay right aligned without extra wrapping', () => {
    const numericKeys = new Set(['index', 'qty', 'unit', 'total']);
    for (const column of TABLE_COLUMNS) {
      if (numericKeys.has(column.key)) {
        expect(column.align).toBe('right');
        expect(column.wrapValue).toBe(false);
      }
    }
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
});
