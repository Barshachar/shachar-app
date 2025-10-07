import { assertEquals } from 'https://deno.land/std@0.224.0/testing/asserts.ts';
import { computeVendorSplits } from './utils.ts';

Deno.test('computeVendorSplits groups totals per vendor', () => {
  const result = computeVendorSplits([
    { vendor_company_id: 'vendor-1', line_total: 10 },
    { vendor_company_id: 'vendor-1', line_total: 5 },
    { vendor_company_id: 'vendor-2', line_total: 20 },
  ]);

  assertEquals(result.length, 2);
  const vendor1 = result.find((split) => split.vendor_company_id === 'vendor-1');
  const vendor2 = result.find((split) => split.vendor_company_id === 'vendor-2');
  assertEquals(vendor1?.total, 15);
  assertEquals(vendor2?.total, 20);
});
