import { assertEquals } from 'https://deno.land/std@0.224.0/testing/asserts.ts';
import { parseCsv } from './index.ts';

Deno.test('parseCsv parses CSV with optional fields', () => {
  const csv = `variant_id,unit_price,min_qty,scope,currency
1111,20.5,5,customer,USD
2222,18.9,,global,ILS`;

  const rows = parseCsv(csv);

  assertEquals(rows.length, 2);
  assertEquals(rows[0], {
    variant_id: '1111',
    unit_price: '20.5',
    min_qty: '5',
    scope: 'customer',
    currency: 'USD',
  });
  assertEquals(rows[1].min_qty, '');
  assertEquals(rows[1].scope, 'global');
  assertEquals(rows[1].currency, 'ILS');
});
