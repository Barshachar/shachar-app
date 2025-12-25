import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { handler } from './index.ts';

type RpcCall = { name: string; args: Record<string, unknown> };

type HandlerDeps = NonNullable<Parameters<typeof handler>[1]>;

function makeRequest(body: Record<string, unknown>, headers: HeadersInit = {}): Request {
  return new Request('http://localhost/admin_user_management', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      ...headers
    },
    body: JSON.stringify(body)
  });
}

function createDeps(overrides: Partial<HandlerDeps> = {}, rpcResult: unknown = { ok: true }): HandlerDeps {
  const rpcCalls: RpcCall[] = [];
  const authedClient = {
    rpc: async (name: string, args: Record<string, unknown>) => {
      rpcCalls.push({ name, args });
      return { data: rpcResult, error: null };
    },
    from: () => ({
      select: () => ({
        eq: () => ({
          eq: () => ({
            maybeSingle: async () => ({ data: { role: 'buyer' }, error: null })
          })
        })
      })
    })
  };
  const serviceClient = {
    rpc: authedClient.rpc,
    from: authedClient.from,
    auth: {
      admin: {
        createUser: async () => ({ data: { user: { id: 'new-user' } }, error: null }),
        inviteUserByEmail: async () => ({})
      }
    }
  };

  return {
    verifyUser: async (_token: string | null) => ({
      userId: 'admin-user',
      companyId: 'tenant-a',
      roles: ['admin'],
      token: 'valid-token'
    }),
    getAuthedClient: () => authedClient as any,
    getServiceClient: () => serviceClient as any,
    ...overrides
  };
}

Deno.test('admin_user_management: missing token returns 401', async () => {
  const deps = createDeps({
    verifyUser: async () => {
      throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
    }
  });
  const responseWithDeps = await handler(makeRequest({}), deps);
  assertEquals(responseWithDeps.status, 401);
  const payload = await responseWithDeps.json();
  assertEquals(payload.error, 'unauthorized');
});

Deno.test('admin_user_management: tenant mismatch returns 403', async () => {
  const response = await handler(
    makeRequest({ company_id: 'tenant-b' }, { authorization: 'Bearer valid-token' }),
    createDeps()
  );
  assertEquals(response.status, 403);
});

Deno.test('admin_user_management: happy path list returns 200', async () => {
  const deps = createDeps();
  const response = await handler(
    makeRequest({ action: 'list' }, { authorization: 'Bearer valid-token' }),
    deps
  );
  assertEquals(response.status, 200);
  const payload = await response.json();
  assertEquals(payload.ok, true);
});
