import { assertEquals, assertRejects } from 'https://deno.land/std@0.224.0/testing/asserts.ts';
import { errorResponse, getServiceClient, jsonResponse } from './client.ts';

Deno.test('jsonResponse wraps payload and sets headers', async () => {
  const response = jsonResponse({ ok: true }, 201);
  assertEquals(response.status, 201);
  assertEquals(response.headers.get('content-type'), 'application/json; charset=utf-8');
  assertEquals(await response.json(), { ok: true });
});

Deno.test('errorResponse wraps message with status', async () => {
  const response = errorResponse('missing', 422);
  assertEquals(response.status, 422);
  assertEquals(await response.json(), { error: 'missing' });
});

Deno.test('getServiceClient throws when env missing', async () => {
  const clientCall = () => getServiceClient();
  await assertRejects(async () => clientCall(), Error, 'Missing Supabase environment variables.');
});
