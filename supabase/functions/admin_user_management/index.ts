import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

type AdminAction = 'list' | 'invite' | 'set_role' | 'deactivate' | 'activate';

type JwtPayload = {
  sub?: string;
  app_metadata?: {
    roles?: string[];
    role?: string;
    company_id?: string;
  };
  user_metadata?: Record<string, unknown>;
  [key: string]: unknown;
};

function decodeJwt(token?: string | null): JwtPayload | null {
  if (!token) {
    return null;
  }
  const parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }
  const payload = parts[1].replace(/-/g, '+').replace(/_/g, '/');
  try {
    const json = atob(payload);
    return JSON.parse(json) as JwtPayload;
  } catch {
    return null;
  }
}

function extractToken(req: Request, body: Record<string, unknown>): string | null {
  const header = req.headers.get('authorization');
  if (header?.startsWith('Bearer ')) {
    return header.slice('Bearer '.length).trim();
  }
  const jwt = body?.jwt;
  return typeof jwt === 'string' && jwt.length > 0 ? jwt : null;
}

function requireAdmin(payload: JwtPayload | null): void {
  const roles: string[] = Array.isArray(payload?.app_metadata?.roles)
    ? (payload?.app_metadata?.roles as string[])
    : [];
  const metadataRole = payload?.app_metadata?.role;
  if (metadataRole) {
    roles.push(metadataRole);
  }
  if (!roles.includes('system_admin') && !roles.includes('admin') && !roles.includes('vendor_admin')) {
    throw new Response(JSON.stringify({ error: 'forbidden' }), { status: 403 });
  }
}

function ensureCompanyScope(payload: JwtPayload | null, requestedCompany?: string): string {
  const scope = requestedCompany ?? payload?.app_metadata?.company_id;
  if (!scope) {
    throw new Response(JSON.stringify({ error: 'company scope required' }), { status: 400 });
  }
  if (payload?.app_metadata?.company_id && payload.app_metadata.company_id !== scope) {
    throw new Response(JSON.stringify({ error: 'tenant mismatch' }), { status: 403 });
  }
  return scope;
}

async function resolveUserRole(
  supabase: ReturnType<typeof getServiceClient>,
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

serve(async (req) => {
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
    const payload = decodeJwt(token);
    requireAdmin(payload);
    const companyId = ensureCompanyScope(payload, body.company_id as string | undefined);
    const action = (body.action as AdminAction | undefined) ?? 'list';
    const supabase = getServiceClient();

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
        const { data: created, error: createError } = await supabase.auth.admin.createUser({
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
          await supabase.auth.admin.inviteUserByEmail(email).catch((err) => {
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
        p_actor: payload?.sub ?? null,
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
        p_actor: payload?.sub ?? null,
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
});
