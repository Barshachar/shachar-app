import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { handleRequest } from './index.ts';

type HandlerDeps = NonNullable<Parameters<typeof handleRequest>[1]>;

type OrderRow = {
  id: string;
  customer_company_id: string;
  status: string;
};

function makeRequest(body: Record<string, unknown>, headers: HeadersInit = {}): Request {
  return new Request('http://localhost/order_cancel_submit', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...headers
    },
    body: JSON.stringify(body)
  });
}

function createDeps(options: {
  order?: OrderRow | null;
  updateError?: { message: string } | null;
} = {}): HandlerDeps {
  const order: OrderRow | null = options.order ?? {
    id: 'order-1',
    customer_company_id: 'tenant-a',
    status: 'placed'
  };

  const authedClient = {
    auth: {
      getUser: async () => ({ data: { user: null }, error: null })
    },
    from: (table: string) => {
      if (table === 'orders') {
        return {
          select: () => ({
            eq: () => ({
              maybeSingle: async () => ({ data: order, error: null })
            })
          }),
          update: () => ({
            eq: () => ({
              select: () => ({
                maybeSingle: async () => ({
                  data: order
                    ? {
                        id: order.id,
                        status: 'cancelled',
                        cancelled_at: 'now',
                        cancelled_by: 'user-1',
                        cancellation_reason: null
                      }
                    : null,
                  error: options.updateError ?? null
                })
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

  const serviceClient = {
    from: (table: string) => {
      if (table === 'shipments') {
        return {
          update: () => ({
            eq: async () => ({ data: [], error: null })
          })
        };
      }
      return {
        update: () => ({
          eq: async () => ({ data: [], error: null })
        })
      };
    },
    functions: {
      invoke: async () => ({ data: { ok: true }, error: null })
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
    getServiceClient: () => serviceClient as any
  };
}

Deno.test('order_cancel_submit: missing token returns 401', async () => {
  const response = await handleRequest(
    makeRequest({ order_id: 'order-1' }),
    {
      ...createDeps(),
      verifyUser: async () => {
        throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
      }
    }
  );
  assertEquals(response.status, 401);
});

Deno.test('order_cancel_submit: rejects non-cancellable status', async () => {
  const response = await handleRequest(
    makeRequest({ order_id: 'order-1' }),
    createDeps({
      order: {
        id: 'order-1',
        customer_company_id: 'tenant-a',
        status: 'shipped'
      }
    })
  );
  assertEquals(response.status, 409);
});

Deno.test('order_cancel_submit: happy path returns ok', async () => {
  const response = await handleRequest(
    makeRequest({ order_id: 'order-1', reason: 'Changed mind' }, { authorization: 'Bearer valid-token' }),
    createDeps()
  );
  assertEquals(response.status, 200);
  const payload = await response.json();
  assertEquals(payload.ok, true);
});
