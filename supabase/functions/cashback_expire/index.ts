import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

// Scheduled maintenance: expire aged cashback by invoking rpc_expire_cashback.
// There is no pg_cron in this project, so this is meant to be triggered on a
// schedule by an external caller (e.g. a cron service or Supabase scheduled
// function) issuing a POST. Returns the number of companies that had cashback
// expired in this run.

export async function handleRequest(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  const supabase = getServiceClient();
  const { data, error } = await supabase.rpc('rpc_expire_cashback');

  if (error) {
    return errorResponse(error.message, 500);
  }

  return jsonResponse({ expired: data ?? 0 });
}

if (import.meta.main) {
  serve(handleRequest);
}
