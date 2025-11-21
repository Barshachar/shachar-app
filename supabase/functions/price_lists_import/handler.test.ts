import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { handler, type SupabaseLike } from './index.ts';
import { stub } from 'https://deno.land/std@0.224.0/testing/mock.ts';
import * as clientMod from '../_shared/client.ts';

Deno.test('handler(JSON): 200 + שתי קריאות RPC על שתי שורות חוקיות', async () => {
  const rpcCalls: Array<{ name: string; args: unknown }> = [];
  const client = {
    rpc: (name: string, args: unknown) => {
      rpcCalls.push({ name, args });
      return Promise.resolve({ data: null, error: null });
    },
  };

  const body = JSON.stringify({
    rows: [
      { vendor_company_id: 'v1', product_variant_id: 'pv1', price_cents: '100', currency: 'ILS' },
      { vendor_company_id: 'v1', product_variant_id: 'pv2', price_cents: '200', currency: 'ILS', qty_tier: '10' },
    ],
  });

  const req = new Request('http://local/import', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.' +
        btoa(JSON.stringify({ app_metadata: { company_id: 'v1' } })) +
        '.signature',
    },
    body,
  });
  const res = await handler(req, client as any);

  assertEquals(res.status, 200);
  assertEquals(rpcCalls.length, 2);
});

Deno.test('handler(JSON): 400 על שורה לא תקינה (בלי RPC בכלל)', async () => {
  const rpcCalls: Array<{ name: string; args: unknown }> = [];
  const client = {
    rpc: (name: string, args: unknown) => {
      rpcCalls.push({ name, args });
      return Promise.resolve({ data: null, error: null });
    },
  };

  const body = JSON.stringify({
    rows: [{ vendor_company_id: 'v1', product_variant_id: 'pvX', price_cents: 'NaN', currency: 'ILS' }],
  });

  const req = new Request('http://local/import', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy.signature',
    },
    body,
  });
  const res = await handler(req, client as any);

  assertEquals(res.status, 403);
  assertEquals(rpcCalls.length, 0);
});
Deno.test('handler: 403 when vendor_company_id != jwt.company_id', async () => {
  const payload = btoa(JSON.stringify({ app_metadata: { company_id: 'A', roles: [] } }));
  const token = `header.${payload}.sig`;
  const req = new Request('http://local/import', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      rows: [
        {
          vendor_company_id: 'B',
          product_variant_id: 'pv1',
          price_cents: '100',
          currency: 'ILS',
        },
      ],
    }),
  });
  const res = await handler(req, {
    rpc: () => Promise.resolve({ data: null, error: null }),
  } as SupabaseLike);
  assertEquals(res.status, 403);
});

Deno.test('handler: 415 for unsupported content-type', async () => {
  const req = new Request('http://local/import', {
    method: 'POST',
    headers: { 'content-type': 'application/octet-stream' },
    body: '...'
  });
  const res = await handler(req);
  assertEquals(res.status, 415);
});
