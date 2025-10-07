import { createClient, SupabaseClient } from '@supabase/supabase-js';

export type Database = unknown;

type ClientType = SupabaseClient<Database>;

function resolveBaseConfig() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anon = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !anon) {
    throw new Error('Missing Supabase server env configuration');
  }
  return { url, anon };
}

export function createServerClient(): ClientType {
  const { url, anon } = resolveBaseConfig();
  return createClient<Database>(url, anon, {
    auth: {
      persistSession: false
    }
  });
}

export function createServiceRoleClient(): ClientType {
  const { url } = resolveBaseConfig();
  const serviceRole = process.env.SUPABASE_SERVICE_ROLE;
  if (!serviceRole) {
    console.warn('SUPABASE_SERVICE_ROLE not configured – falling back to anon client. Ensure RLS policies permit the requested operations.');
    return createServerClient();
  }
  return createClient<Database>(url, serviceRole, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
}
