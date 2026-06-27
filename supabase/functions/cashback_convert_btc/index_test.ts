import { assertEquals } from 'https://deno.land/std@0.224.0/testing/asserts.ts';
import { handleRequest, isEnabled } from './index.ts';

function postRequest(body: unknown): Request {
  return new Request('http://localhost/cashback_convert_btc', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });
}

Deno.test('returns 501 when the BTC flag is disabled', async () => {
  Deno.env.delete('CASHBACK_BTC_ENABLED');
  assertEquals(isEnabled(), false);

  const res = await handleRequest(
    postRequest({ customer_company_id: 'c1', amount_ils: 100 }),
  );
  assertEquals(res.status, 501);
  const json = await res.json();
  assertEquals(json.error, 'not_implemented');
});

Deno.test('rejects non-POST methods', async () => {
  const res = await handleRequest(
    new Request('http://localhost/cashback_convert_btc', { method: 'GET' }),
  );
  assertEquals(res.status, 405);
});

Deno.test('validates input when the flag is enabled', async () => {
  Deno.env.set('CASHBACK_BTC_ENABLED', 'true');
  try {
    const res = await handleRequest(postRequest({ amount_ils: 100 }));
    assertEquals(res.status, 400);
    const json = await res.json();
    assertEquals(json.error, 'customer_company_id is required');
  } finally {
    Deno.env.delete('CASHBACK_BTC_ENABLED');
  }
});
