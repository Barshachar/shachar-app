import { assertEquals } from 'https://deno.land/std@0.224.0/testing/asserts.ts';
import { handleRequest } from './index.ts';

Deno.test('rejects non-POST methods', async () => {
  const res = await handleRequest(
    new Request('http://localhost/cashback_expire', { method: 'GET' }),
  );
  assertEquals(res.status, 405);
  const json = await res.json();
  assertEquals(json.error, 'Use POST');
});

Deno.test('rejects POST without the cron secret when one is configured', async () => {
  Deno.env.set('CASHBACK_CRON_SECRET', 'top-secret');
  try {
    const res = await handleRequest(
      new Request('http://localhost/cashback_expire', {
        method: 'POST',
        headers: { authorization: 'Bearer wrong' },
      }),
    );
    assertEquals(res.status, 401);
    const json = await res.json();
    assertEquals(json.error, 'Unauthorized');
  } finally {
    Deno.env.delete('CASHBACK_CRON_SECRET');
  }
});
