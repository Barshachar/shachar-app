import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { type SupabaseClient, type User } from 'https://esm.sh/@supabase/supabase-js@2.43.0';

import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

type ActionPayload =
  | ({ action: 'invite' } & InvitePayload)
  | ({ action: 'deactivate' } & TargetPayload)
  | ({ action: 'activate' } & TargetPayload);

type InvitePayload = {
  email: string;
  role: string;
  full_name?: string;
};

type TargetPayload = {
  user_id: string;
  reason?: string;
};

type ActorContext = {
  user: User;
  companyId: string;
};

const VALID_ROLES = new Set([
  'admin',
  'vendor_admin',
  'vendor_user',
  'customer_admin',
  'buyer',
]);

serve(async (req) => {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  let payload: ActionPayload;
  try {
    payload = (await req.json()) as ActionPayload;
  } catch (_error) {
    return errorResponse('Invalid JSON payload', 400);
  }

  const supabase = getServiceClient();
  const actorAuth = await resolveActor(req, supabase);
  if ('error' in actorAuth) {
    return actorAuth.error;
  }

  const { user, companyId } = actorAuth;

  switch (payload.action) {
    case 'invite':
      return await handleInvite(supabase, user, companyId, payload);
    case 'deactivate':
      return await handleDeactivate(supabase, user, companyId, payload);
    case 'activate':
      return await handleActivate(supabase, user, companyId, payload);
    default:
      return errorResponse(`Unsupported action: ${String((payload as { action?: unknown }).action)}`, 400);
  }
});

type ActorResolution = ActorContext | { error: Response };

async function resolveActor(req: Request, supabase: SupabaseClient): Promise<ActorResolution> {
  const header = req.headers.get('Authorization') ?? req.headers.get('authorization');
  if (!header || !header.toLowerCase().startsWith('bearer ')) {
    return { error: errorResponse('Missing bearer token', 401) };
  }
  const token = header.replace(/bearer /i, '').trim();
  if (!token) {
    return { error: errorResponse('Missing bearer token', 401) };
  }

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data?.user) {
    return { error: errorResponse('Unauthorized', 401) };
  }

  const actor = data.user;
  const role = String(actor.app_metadata?.role ?? actor.user_metadata?.role ?? '').toLowerCase();
  if (role !== 'admin') {
    return { error: errorResponse('Forbidden', 403) };
  }

  const companyId = String(
    actor.app_metadata?.company_id ?? actor.user_metadata?.company_id ?? '',
  ).trim();
  if (!companyId) {
    return { error: errorResponse('Admin missing company scope', 403) };
  }

  return { user: actor, companyId };
}

async function handleInvite(
  supabase: SupabaseClient,
  actor: User,
  companyId: string,
  payload: InvitePayload,
): Promise<Response> {
  const email = (payload.email ?? '').trim().toLowerCase();
  const role = (payload.role ?? '').trim().toLowerCase();
  const fullName = typeof payload.full_name === 'string' ? payload.full_name.trim() : undefined;

  if (!email) {
    return errorResponse('email is required', 400);
  }
  if (!VALID_ROLES.has(role)) {
    return errorResponse('invalid role', 400);
  }

  const { data: company, error: companyError } = await supabase
    .from('companies')
    .select('id, name, type')
    .eq('id', companyId)
    .maybeSingle();

  if (companyError) {
    return errorResponse(companyError.message, 500);
  }
  if (!company) {
    return errorResponse('Company not found for admin scope', 404);
  }

  const inviteData = await supabase.auth.admin.inviteUserByEmail(email, {
    data: {
      ...(fullName ? { full_name: fullName } : {}),
      invited_by: actor.email ?? actor.user_metadata?.full_name ?? actor.id,
      company_id: companyId,
      role,
    },
  });

  let invitedUser = inviteData.data?.user ?? null;
  if (inviteData.error) {
    const message = (inviteData.error.message ?? '').toLowerCase();
    if (!message.includes('already registered')) {
      return errorResponse(inviteData.error.message, 400);
    }
  }

  if (!invitedUser) {
    const { data: listData, error: listError } = await supabase.auth.admin.listUsers({ email });
    if (listError) {
      return errorResponse(listError.message, 500);
    }
    invitedUser = listData?.users?.find((candidate) => candidate.email?.toLowerCase() === email) ?? null;
    if (!invitedUser) {
      return errorResponse('User already exists but could not be loaded', 500);
    }
  }

  const mergedAppMetadata = {
    ...(invitedUser.app_metadata ?? {}),
    role,
    company_id: companyId,
    company_type: company.type,
  } as Record<string, unknown>;

  const mergedUserMetadata = {
    ...(invitedUser.user_metadata ?? {}),
    invited_by: actor.email ?? actor.user_metadata?.full_name ?? actor.id,
  } as Record<string, unknown>;
  if (fullName) {
    mergedUserMetadata.full_name = fullName;
  }

  const updateResponse = await supabase.auth.admin.updateUserById(invitedUser.id, {
    app_metadata: mergedAppMetadata,
    user_metadata: mergedUserMetadata,
    banned_until: null,
  });
  if (updateResponse.error) {
    return errorResponse(updateResponse.error.message, 500);
  }

  const linkResponse = await supabase
    .from('company_users')
    .upsert({ company_id: companyId, user_id: invitedUser.id, role }, { onConflict: 'company_id,user_id' });
  if (linkResponse.error) {
    return errorResponse(linkResponse.error.message, 500);
  }

  await supabase.from('audit_log').insert({
    actor_user_id: actor.id,
    action: 'admin_user_invited',
    table_name: 'company_users',
    row_id: invitedUser.id,
    metadata: {
      email,
      role,
      company_id: companyId,
      company_name: company.name,
    },
  });

  return jsonResponse({
    status: 'invited',
    user_id: invitedUser.id,
  });
}

async function handleDeactivate(
  supabase: SupabaseClient,
  actor: User,
  companyId: string,
  payload: TargetPayload,
): Promise<Response> {
  const userId = (payload.user_id ?? '').trim();
  if (!userId) {
    return errorResponse('user_id is required', 400);
  }

  const membership = await supabase
    .from('company_users')
    .select('company_id, role')
    .eq('company_id', companyId)
    .eq('user_id', userId)
    .maybeSingle();

  if (membership.error) {
    return errorResponse(membership.error.message, 500);
  }
  if (!membership.data) {
    return errorResponse('User does not belong to this tenant', 403);
  }

  const target = await supabase.auth.admin.getUserById(userId);
  if (target.error || !target.data?.user) {
    return errorResponse('User not found', 404);
  }

  const bannedUntil = '2099-12-31T23:59:59Z';
  const currentApp = { ...(target.data.user.app_metadata ?? {}) } as Record<string, unknown>;
  const currentUserMeta = { ...(target.data.user.user_metadata ?? {}) } as Record<string, unknown>;

  currentApp.disabled = true;
  currentUserMeta.deactivated_at = new Date().toISOString();
  if (payload.reason) {
    currentUserMeta.deactivation_reason = payload.reason;
  }

  const updateResponse = await supabase.auth.admin.updateUserById(userId, {
    app_metadata: currentApp,
    user_metadata: currentUserMeta,
    banned_until: bannedUntil,
  });
  if (updateResponse.error) {
    return errorResponse(updateResponse.error.message, 500);
  }

  await supabase.from('audit_log').insert({
    actor_user_id: actor.id,
    action: 'admin_user_deactivated',
    table_name: 'company_users',
    row_id: userId,
    metadata: {
      company_id: companyId,
      reason: payload.reason,
    },
  });

  return jsonResponse({ status: 'deactivated', user_id: userId });
}

async function handleActivate(
  supabase: SupabaseClient,
  actor: User,
  companyId: string,
  payload: TargetPayload,
): Promise<Response> {
  const userId = (payload.user_id ?? '').trim();
  if (!userId) {
    return errorResponse('user_id is required', 400);
  }

  const membership = await supabase
    .from('company_users')
    .select('company_id, role')
    .eq('company_id', companyId)
    .eq('user_id', userId)
    .maybeSingle();

  if (membership.error) {
    return errorResponse(membership.error.message, 500);
  }
  if (!membership.data) {
    return errorResponse('User does not belong to this tenant', 403);
  }

  const target = await supabase.auth.admin.getUserById(userId);
  if (target.error || !target.data?.user) {
    return errorResponse('User not found', 404);
  }

  const currentApp = { ...(target.data.user.app_metadata ?? {}) } as Record<string, unknown>;
  const currentUserMeta = { ...(target.data.user.user_metadata ?? {}) } as Record<string, unknown>;

  delete currentApp.disabled;
  delete currentUserMeta.deactivated_at;
  delete currentUserMeta.deactivation_reason;

  const updateResponse = await supabase.auth.admin.updateUserById(userId, {
    app_metadata: currentApp,
    user_metadata: currentUserMeta,
    banned_until: null,
  });
  if (updateResponse.error) {
    return errorResponse(updateResponse.error.message, 500);
  }

  await supabase.from('audit_log').insert({
    actor_user_id: actor.id,
    action: 'admin_user_reactivated',
    table_name: 'company_users',
    row_id: userId,
    metadata: {
      company_id: companyId,
    },
  });

  return jsonResponse({ status: 'activated', user_id: userId });
}
