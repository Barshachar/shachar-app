import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { handleRequest } from './index.ts';

type HandlerDeps = NonNullable<Parameters<typeof handleRequest>[1]>;

function makeRequest(body: Record<string, unknown>, headers: HeadersInit = {}): Request {
  return new Request('http://localhost/return_request_submit', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...headers
    },
    body: JSON.stringify(body)
  });
}

function createDeps(overrides: Partial<HandlerDeps> = {}): HandlerDeps {
  const authedClient = {
    auth: {
      getUser: async () => ({ data: { user: null }, error: null })
    },
    from: (table: string) => {
      if (table === 'orders') {
        return {
          select: () => ({
            eq: () => ({
              maybeSingle: async () => ({
                data: {
                  id: 'order-1',
                  customer_company_id: 'tenant-a',
                  status: 'delivered'
                },
                error: null
              })
            })
          })
        };
      }
      if (table === 'order_items') {
        return {
          select: () => ({
            eq: () => ({
              eq: () => ({
                maybeSingle: async () => ({
                  data: { id: 'item-1', qty: 5 },
                  error: null
                })
              })
            })
          })
        };
      }
      if (table === 'returns') {
        return {
          select: () => ({
            eq: async () => ({ data: [], error: null })
          }),
          insert: () => ({
            select: () => ({
              maybeSingle: async () => ({
                data: {
                  id: 'return-1',
                  order_id: 'order-1',
                  item_id: 'item-1',
                  qty: 2,
                  reason: null,
                  status: 'requested',
                  created_at: 'now',
                  created_by: 'user-1'
                },
                error: null
              })
            })
          })
        };
      }
      return {
        select: () => ({
          eq: async () => ({ data: null, error: null })
        })
      };
    }
  };

  return {
    verifyUser: async (_token: string | null) => ({
      userId: 'user-1',
      companyId: 'tenant-a',
      roles: ['buyer'],
      token: 'valid-token'
    }),
    getAuthedClient: () => authedClient as any,
    ...overrides
  };
}

Deno.test('return_request_submit: missing token returns 401', async () => {
  const deps = createDeps({
    verifyUser: async () => {
      throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
    }
  });
  const response = await handleRequest(makeRequest({}), deps);
  assertEquals(response.status, 401);
});

Deno.test('return_request_submit: happy path returns ok', async () => {
  const response = await handleRequest(
    makeRequest(
      { order_id: 'order-1', order_item_id: 'item-1', qty: 2 },
      { authorization: 'Bearer valid-token' }
    ),
    createDeps()
  );
  assertEquals(response.status, 200);
  const payload = await response.json();
  assertEquals(payload.ok, true);
});
