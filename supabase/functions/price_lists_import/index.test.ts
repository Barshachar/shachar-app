import { assertEquals, assertRejects } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { stub } from 'https://deno.land/std@0.224.0/testing/mock.ts';
import * as clientMod from '../_shared/client.ts';
import { importPriceList, type SupabaseLike, type CsvRow } from './index.ts';

type RpcCall = { name: string; args: Record<string, unknown> };

Deno.test('importPriceList validates rows and invokes RPC per row', async () => {
  const rows: Array<Record<string, string>> = [
    {
      vendor_company_id: 'vendor-1',
      product_variant_id: 'pv-1',
      price_cents: '100',
      currency: 'USD',
      qty_tier: '5',
    },
    {
      vendor_company_id: 'vendor-1',
      product_variant_id: 'pv-2',
      price_cents: '250',
      currency: 'ILS',
    },
  ];
  const rpcCalls: RpcCall[] = [];
  const client: SupabaseLike = {
    rpc: (name, args) => {
      rpcCalls.push({ name, args });
      return Promise.resolve({ data: null, error: null });
    },
  };

  await importPriceList(client, rows);

  assertEquals(rpcCalls.length, 2);
  assertEquals(rpcCalls[0].name, 'rpc_upsert_prices');
  const firstRow = rpcCalls[0].args.row as CsvRow;
  assertEquals(firstRow.price_cents, 100);
  assertEquals(firstRow.qty_tier, 5);
  const secondRow = rpcCalls[1].args.row as CsvRow;
  assertEquals(secondRow.currency, 'ILS');
});

Deno.test('importPriceList surfaces validation and RPC errors', async () => {
  const failingClient: SupabaseLike = {
    rpc: () =>
      Promise.resolve({
        data: null,
        error: { message: 'database unavailable' },
      }),
  };

  await assertRejects(
    () =>
      importPriceList(failingClient, [
        {
          vendor_company_id: 'vendor-1',
          product_variant_id: 'pv-1',
          price_cents: 'not-a-number',
          currency: 'USD',
        },
      ]),
    Error,
    'Invalid price_cents',
  );

  await assertRejects(
    () =>
      importPriceList(failingClient, [
        {
          vendor_company_id: 'vendor-1',
          product_variant_id: 'pv-1',
          price_cents: '100',
          currency: 'USD',
        },
      ]),
    Error,
    'database unavailable',
  );
});

Deno.test('importPriceList rejects invalid rows and makes zero RPC calls', async () => {
  const rpcCalls: Array<{ name: string; args: unknown }> = [];
  const client: SupabaseLike = {
    rpc: (name: string, args: unknown) => {
      rpcCalls.push({ name, args });
      return Promise.resolve({ data: null, error: null });
    },
  };

  const badRows = [
    { vendor_company_id: 'v1', product_variant_id: 'pv1', price_cents: 'abc', currency: 'ILS' },
  ];
  await assertRejects(() => importPriceList(client, badRows));
  assertEquals(rpcCalls.length, 0);
});
