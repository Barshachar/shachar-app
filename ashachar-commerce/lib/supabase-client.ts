'use client';

import { createClient, SupabaseClient } from '@supabase/supabase-js';

type Database = unknown;

let client: SupabaseClient<Database> | null = null;

export function getSupabaseBrowserClient(): SupabaseClient<Database> {
  if (client) {
    return client;
  }
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !anonKey) {
    throw new Error('Missing Supabase browser env configuration');
  }
  client = createClient<Database>(url, anonKey, {
    auth: {
      persistSession: true
    }
  });
  return client;
}
