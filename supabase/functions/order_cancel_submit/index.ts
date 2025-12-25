import { serve, type Handler } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient, type SupabaseClient, type User } from 'https://esm.sh/@supabase/supabase-js@2.43.0';
import { errorResponse, getServiceClient, jsonResponse } from '../_shared/client.ts';

type VerifiedUser = {
  userId: string;
  companyId: string;
  roles: string[];
  token: string;
};

type SupabaseLike = Pick<SupabaseClient, 'from' | 'auth'>;

type ServiceClientLike = Pick<SupabaseClient, 'from' | 'functions'>;

type HandlerDeps = {
  getAuthedClient: (token: string) => SupabaseLike;
  getServiceClient: () => ServiceClientLike;
  verifyUser: (token: string | null) => Promise<VerifiedUser>;
};

type OrderRow = {
  id: string;
  customer_company_id: string;
  status: string;
};

function extractToken(req: Request, body: Record<string, unknown>): string | null {
  const header = req.headers.get('authorization');
  if (header?.startsWith('Bearer ')) {
    return header.slice('Bearer '.length).trim();
  }
  const jwt = body?.jwt;
  return typeof jwt === 'string' && jwt.length > 0 ? jwt : null;
}

function requireEnv(key: string): string {
  const value = Deno.env.get(key);
  if (!value) {
    throw new Error(`Missing env var ${key}`);
  }
  return value;
}

function makeAuthedClient(token: string): SupabaseClient {
  const url = requireEnv('SUPABASE_URL');
  const anonKey = requireEnv('SUPABASE_ANON_KEY');
  return createClient(url, anonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`
      }
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
}

function normalizeRoles(user: User): string[] {
  const roles: string[] = [];
  const metaRoles = Array.isArray(user.app_metadata?.roles) ? user.app_metadata?.roles : [];
  for (const role of metaRoles) {
    if (typeof role === 'string' && role.length > 0) {
      roles.push(role);
    }
  }
  const primary = user.app_metadata?.role;
  if (typeof primary === 'string' && primary.length > 0) {
    roles.push(primary);
  }
  return Array.from(new Set(roles));
}

async function verifyUser(token: string | null): Promise<VerifiedUser> {
  if (!token) {
    throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }
  const supabase = makeAuthedClient(token);
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) {
    throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }
  const user = data.user;
  const companyId = (user.app_metadata?.company_id as string | undefined)?.trim();
  if (!companyId) {
    throw new Response(JSON.stringify({ error: 'company scope required' }), { status: 403 });
  }
  const roles = normalizeRoles(user);
  const allowed = roles.some((role) => role === 'buyer' || role === 'customer_admin');
  if (!allowed) {
    throw new Response(JSON.stringify({ error: 'forbidden' }), { status: 403 });
  }
  return {
    userId: user.id,
    companyId,
    roles,
    token
  };
}

const cancellableStatuses = new Set(['draft', 'placed', 'confirmed', 'picking', 'approved']);

const defaultDeps: HandlerDeps = {
  getAuthedClient: makeAuthedClient,
  getServiceClient,
  verifyUser
};

export async function handleRequest(
  req: Request,
  deps: HandlerDeps = defaultDeps
): Promise<Response> {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  let body: Record<string, unknown> = {};
  try {
    body = (await req.json()) as Record<string, unknown>;
  } catch {
    body = {};
  }

  try {
    const token = extractToken(req, body);
    const verified = await deps.verifyUser(token);
    const orderId = typeof body.order_id === 'string' ? body.order_id.trim() : '';
    const reasonRaw = typeof body.reason === 'string' ? body.reason.trim() : '';

    if (!orderId) {
      return errorResponse('order_id is required', 400);
    }
    if (reasonRaw.length > 500) {
      return errorResponse('reason is too long', 400);
    }

    const supabase = deps.getAuthedClient(verified.token);

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('id, customer_company_id, status')
      .eq('id', orderId)
      .maybeSingle<OrderRow>();

    if (orderError || !order) {
      return errorResponse('order not found', 404);
    }
    if (order.customer_company_id !== verified.companyId) {
      return errorResponse('forbidden', 403);
    }

    const status = (order.status ?? '').toLowerCase();
    if (status === 'cancelled') {
      return errorResponse('order already cancelled', 409);
    }
    if (!cancellableStatuses.has(status)) {
      return errorResponse('order cannot be cancelled in current status', 409);
    }

    const now = new Date().toISOString();
    const { data: updated, error: updateError } = await supabase
      .from('orders')
      .update({
        status: 'cancelled',
        cancelled_at: now,
        cancelled_by: verified.userId,
        cancellation_reason: reasonRaw.length ? reasonRaw : null,
        updated_at: now
      })
      .eq('id', orderId)
      .select('id, status, cancelled_at, cancelled_by, cancellation_reason')
      .maybeSingle();

    if (updateError || !updated) {
      return errorResponse(updateError?.message ?? 'failed to cancel order', 500);
    }

    const service = deps.getServiceClient();
    const { error: shipmentsError } = await service
      .from('shipments')
      .update({ status: 'cancelled', updated_at: now })
      .eq('order_id', orderId);

    if (shipmentsError) {
      return errorResponse(shipmentsError.message ?? 'failed to update shipments', 500);
    }

    try {
      await service.functions.invoke('notify_status_change', {
        body: {
          order_id: orderId,
          event: 'cancelled'
        }
      });
    } catch (_) {
      // Best-effort notification only.
    }

    return jsonResponse({ ok: true, order: updated });
  } catch (error) {
    if (error instanceof Response) {
      return error;
    }
    return errorResponse('unexpected error', 500);
  }
}

const handler: Handler = (req) => handleRequest(req);

if (import.meta.main) {
  serve(handler);
}
