import { serve, type Handler } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient, type SupabaseClient, type User } from 'https://esm.sh/@supabase/supabase-js@2.43.0';
import { errorResponse, jsonResponse } from '../_shared/client.ts';

type VerifiedUser = {
  userId: string;
  companyId: string;
  roles: string[];
  token: string;
};

type SupabaseLike = Pick<SupabaseClient, 'from' | 'auth'>;

type HandlerDeps = {
  getAuthedClient: (token: string) => SupabaseLike;
  verifyUser: (token: string | null) => Promise<VerifiedUser>;
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

const defaultDeps: HandlerDeps = {
  getAuthedClient: makeAuthedClient,
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
    const vendorCompanyId =
      typeof body.vendor_company_id === 'string' ? body.vendor_company_id.trim() : '';
    const ratingValue = Number(body.rating);
    const commentRaw = typeof body.comment === 'string' ? body.comment.trim() : '';

    if (!orderId || !vendorCompanyId) {
      return errorResponse('order_id and vendor_company_id are required', 400);
    }
    if (!Number.isFinite(ratingValue) || ratingValue < 1 || ratingValue > 5) {
      return errorResponse('rating must be between 1 and 5', 400);
    }
    if (commentRaw.length > 500) {
      return errorResponse('comment is too long', 400);
    }

    const supabase = deps.getAuthedClient(verified.token);

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('id, customer_company_id')
      .eq('id', orderId)
      .maybeSingle<{ id: string; customer_company_id: string }>();
    if (orderError || !order) {
      return errorResponse('order not found', 404);
    }
    if (order.customer_company_id !== verified.companyId) {
      return errorResponse('forbidden', 403);
    }

    const { data: item, error: itemError } = await supabase
      .from('order_items')
      .select('id')
      .eq('order_id', orderId)
      .eq('vendor_company_id', vendorCompanyId)
      .maybeSingle<{ id: string }>();
    if (itemError || !item) {
      return errorResponse('vendor not part of order', 403);
    }

    const { data: rating, error } = await supabase
      .from('vendor_ratings')
      .insert({
        order_id: orderId,
        vendor_company_id: vendorCompanyId,
        customer_company_id: verified.companyId,
        rating: Math.round(ratingValue),
        comment: commentRaw.length ? commentRaw : null,
        created_by: verified.userId
      })
      .select(
        'id, vendor_company_id, customer_company_id, order_id, rating, comment, created_at, created_by'
      )
      .maybeSingle();

    if (error) {
      if ((error as { code?: string }).code === '23505') {
        return errorResponse('rating already submitted', 409);
      }
      return errorResponse(error.message ?? 'failed to submit rating', 500);
    }

    return jsonResponse({ ok: true, rating });
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
