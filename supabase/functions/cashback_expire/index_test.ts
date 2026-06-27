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
