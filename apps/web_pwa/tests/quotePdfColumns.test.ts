import { describe, expect, test } from 'vitest';
import { NUMERIC_COLUMN_KEYS, TABLE_COLUMNS } from '@/app/api/quote/route';

describe('quote PDF RTL layout', () => {
  test('uses prescribed RTL column order', () => {
    const keys = TABLE_COLUMNS.map((column) => column.key);
    expect(keys).toEqual(['index', 'name', 'sku', 'qty', 'unit', 'total']);
  });

  test('right-aligns every numeric column', () => {
    const numericColumns = TABLE_COLUMNS.filter((column) =>
      NUMERIC_COLUMN_KEYS.has(column.key)
    );
    expect(numericColumns.length).toBe(NUMERIC_COLUMN_KEYS.size);
    for (const column of numericColumns) {
      expect(column.align).toBe('right');
    }
  });
});
