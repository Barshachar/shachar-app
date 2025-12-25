import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { handleRequest } from './index.ts';

type HandlerDeps = NonNullable<Parameters<typeof handleRequest>[1]>;

function makeRequest(body: Record<string, unknown>, headers: HeadersInit = {}): Request {
  return new Request('http://localhost/support_ai_assistant', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...headers
    },
    body: JSON.stringify(body)
  });
}

function createDeps(overrides: Partial<HandlerDeps> = {}): HandlerDeps {
  return {
    verifyUser: async (_token: string | null) => ({
      userId: 'user-1',
      token: 'valid-token'
    }),
    getAuthedClient: () => ({} as any),
    ...overrides
  };
}

Deno.test('support_ai_assistant: missing token returns 401', async () => {
  const deps = createDeps({
    verifyUser: async () => {
      throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
    }
  });
  const response = await handleRequest(makeRequest({}), deps);
  assertEquals(response.status, 401);
});

Deno.test('support_ai_assistant: responds to message', async () => {
  const response = await handleRequest(
    makeRequest({ message: 'Track my order' }, { authorization: 'Bearer valid-token' }),
    createDeps()
  );
  assertEquals(response.status, 200);
  const payload = await response.json();
  assertEquals(payload.ok, true);
});
