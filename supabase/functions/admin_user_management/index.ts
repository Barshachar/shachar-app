import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient, type SupabaseClient, type User } from 'https://esm.sh/@supabase/supabase-js@2.43.0';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

type AdminAction = 'list' | 'invite' | 'set_role' | 'deactivate' | 'activate';

type VerifiedUser = {
  userId: string;
  companyId: string;
  roles: string[];
  token: string;
};

type SupabaseLike = Pick<SupabaseClient, 'rpc' | 'from'>;

function extractToken(req: Request, body: Record<string, unknown>): string | null {
  const header = req.headers.get('authorization');
  if (header?.startsWith('Bearer ')) {
    return header.slice('Bearer '.length).trim();
  }
  const jwt = body?.jwt;
  return typeof jwt === 'string' && jwt.length > 0 ? jwt : null;
}

async function resolveUserRole(
  supabase: SupabaseLike,
  companyId: string,
  userId: string
): Promise<string | null> {
  const { data, error } = await supabase
    .from('company_users')
    .select('role')
    .eq('company_id', companyId)
    .eq('user_id', userId)
    .maybeSingle<{ role: string }>();
  if (error) {
    console.error('resolveUserRole error', error);
    return null;
  }
  return data?.role ?? null;
}

function unauthorized(message = 'unauthorized'): Response {
  return new Response(JSON.stringify({ error: message }), { status: 401 });
}

function forbidden(message = 'forbidden'): Response {
  return new Response(JSON.stringify({ error: message }), { status: 403 });
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
  const rawRoles = Array.isArray(user.app_metadata?.roles) ? user.app_metadata?.roles : [];
  const role = user.app_metadata?.role;
  const merged = [...rawRoles];
  if (typeof role === 'string' && role.length > 0) {
    merged.push(role);
  }
  return Array.from(new Set(merged));
}

async function verifyUser(token: string | null): Promise<VerifiedUser> {
  if (!token) {
    throw unauthorized();
  }
  const supabase = makeAuthedClient(token);
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) {
    throw unauthorized();
  }
  const user = data.user;
  const companyId = (user.app_metadata?.company_id as string | undefined)?.trim();
  if (!companyId) {
    throw forbidden('company scope required');
  }
  const roles = normalizeRoles(user);
  if (!roles.includes('system_admin') && !roles.includes('admin') && !roles.includes('vendor_admin')) {
    throw forbidden();
  }
  return {
    userId: user.id,
    companyId,
    roles,
    token
  };
}

type HandlerDeps = {
  getServiceClient: () => SupabaseClient;
  getAuthedClient: (token: string) => SupabaseClient;
  verifyUser: (token: string | null) => Promise<VerifiedUser>;
};

const defaultDeps: HandlerDeps = {
  getServiceClient,
  getAuthedClient: makeAuthedClient,
  verifyUser
};

export async function handler(req: Request, deps: HandlerDeps = defaultDeps): Promise<Response> {
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
    const bodyCompanyId = typeof body.company_id === 'string' ? (body.company_id as string) : undefined;
    if (bodyCompanyId && bodyCompanyId !== verified.companyId) {
      return forbidden('tenant mismatch');
    }
    const companyId = verified.companyId;
    const action = (body.action as AdminAction | undefined) ?? 'list';
    const supabase = deps.getAuthedClient(verified.token);
    const serviceClient = deps.getServiceClient();

    if (action === 'list') {
      const { data, error } = await supabase.rpc('admin_list_company_users', {
        p_company_id: companyId
      });
      if (error) {
        console.error('admin_list_company_users failed', error);
        return errorResponse(error.message, 500);
      }
      return jsonResponse({ ok: true, users: data ?? [] });
    }

    if (action === 'invite') {
      const email = (body.user_email as string) ?? (body.email as string) ?? '';
      const role = (body.role as string) ?? 'buyer';
      const fullNameRaw = (body.full_name as string | undefined)?.trim();
      if (!email) {
        return errorResponse('user_email is required', 400);
      }

      let userId: string | null = null;
      const { data: existing } = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle<{ id: string }>();
      if (existing?.id) {
        userId = existing.id;
      } else {
        const { data: created, error: createError } = await serviceClient.auth.admin.createUser({
          email,
          email_confirm: false,
          app_metadata: {
            company_id: companyId,
            role
          },
          user_metadata: {
            full_name: fullNameRaw ?? ''
          }
        });
        if (createError) {
          console.error('invite createUser failed', createError);
          return errorResponse(createError.message, 500);
        }
        userId = created?.user?.id ?? null;
        if (userId) {
          await serviceClient.auth.admin.inviteUserByEmail(email).catch((err) => {
            console.warn('inviteUserByEmail warning', err);
          });
        }
      }

      if (!userId) {
        return errorResponse('Failed to create or locate user', 500);
      }

      const { error: rpcError } = await supabase.rpc('admin_set_user_role', {
        p_company_id: companyId,
        p_user_id: userId,
        p_role: role,
        p_active: true,
        p_actor: verified.userId,
        p_reason: body.reason ?? null
      });
      if (rpcError) {
        console.error('admin_set_user_role invite failed', rpcError);
        return errorResponse(rpcError.message, 500);
      }

      return jsonResponse({ ok: true, user_id: userId });
    }

    if (action === 'set_role' || action === 'activate' || action === 'deactivate') {
      const targetUserId = body.user_id as string | undefined;
      if (!targetUserId) {
        return errorResponse('user_id is required', 400);
      }
      const desiredRole = (body.role as string | undefined) ?? (await resolveUserRole(supabase, companyId, targetUserId));
      if (!desiredRole) {
        return errorResponse('Unable to resolve user role', 400);
      }
      const activeFlag =
        action === 'deactivate' ? false : action === 'activate' ? true : (body.active as boolean | undefined) ?? true;

      const { error: rpcError } = await supabase.rpc('admin_set_user_role', {
        p_company_id: companyId,
        p_user_id: targetUserId,
        p_role: desiredRole,
        p_active: activeFlag,
        p_actor: verified.userId,
        p_reason: body.reason ?? null
      });
      if (rpcError) {
        console.error('admin_set_user_role failed', rpcError);
        return errorResponse(rpcError.message, 500);
      }

      return jsonResponse({ ok: true, user_id: targetUserId });
    }

    return errorResponse('unknown action', 400);
  } catch (err) {
    if (err instanceof Response) {
      return err;
    }
    console.error('admin_user_management error', err);
    return errorResponse(err instanceof Error ? err.message : 'unexpected error', 500);
  }
}

if (import.meta.main) {
  serve((req) => handler(req));
}
