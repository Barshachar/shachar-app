import { serve, type Handler } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient, type SupabaseClient, type User } from 'https://esm.sh/@supabase/supabase-js@2.43.0';
import { errorResponse, jsonResponse } from '../_shared/client.ts';

type VerifiedUser = {
  userId: string;
  token: string;
};

type HandlerDeps = {
  getAuthedClient: (token: string) => SupabaseClient;
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

async function verifyUser(token: string | null): Promise<VerifiedUser> {
  if (!token) {
    throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }
  const supabase = makeAuthedClient(token);
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) {
    throw new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }
  const user = data.user as User;
  return { userId: user.id, token };
}

const defaultDeps: HandlerDeps = {
  getAuthedClient: makeAuthedClient,
  verifyUser
};

function buildReply(message: string): { reply: string; suggestions: string[] } {
  const normalized = message.toLowerCase();
  if (normalized.includes('order') || normalized.includes('הזמנה')) {
    return {
      reply:
        'You can track orders from Orders > Order Detail. Use the reorder button to repeat a past order.',
      suggestions: ['Track my order', 'Reorder last order', 'Change delivery notes']
    };
  }
  if (normalized.includes('invoice') || normalized.includes('חשבונית')) {
    return {
      reply:
        'Invoices appear under Billing once an order is confirmed. If you need a resend, open Support > Tickets.',
      suggestions: ['Find my invoice', 'Payment terms', 'Billing contact']
    };
  }
  if (normalized.includes('rating') || normalized.includes('דירוג')) {
    return {
      reply:
        'You can rate vendors from the Order Detail screen after delivery. Ratings help other buyers.',
      suggestions: ['Rate a vendor', 'View vendor ratings']
    };
  }
  if (normalized.includes('return') || normalized.includes('החזר')) {
    return {
      reply:
        'Returns are managed from the Order Detail screen. Check shipment status before starting a return.',
      suggestions: ['Start a return', 'Check shipment status']
    };
  }

  return {
    reply:
      'I can help with order tracking, invoices, approvals, and vendor info. What would you like to do?',
    suggestions: ['Track an order', 'Find invoices', 'Contact support']
  };
}

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
    await deps.verifyUser(token);
    const message = typeof body.message === 'string' ? body.message.trim() : '';
    if (!message) {
      return errorResponse('message is required', 400);
    }
    const { reply, suggestions } = buildReply(message);
    return jsonResponse({ ok: true, reply, suggestions });
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
