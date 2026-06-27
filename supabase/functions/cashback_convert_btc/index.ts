import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

// Converts a customer's ILS cashback into Bitcoin via a regulated provider.
//
// IMPORTANT: This is a STUB. Real conversion is gated behind CASHBACK_BTC_ENABLED
// and is intentionally not implemented yet — turning it on requires a regulated
// provider integration plus Israeli regulatory/tax sign-off (VAT, capital gains,
// AML/KYC, licensing). While the flag is off the endpoint returns 501 so callers
// can detect availability without any conversion ever happening.

export interface ConvertRequest {
  customer_company_id?: string;
  amount_ils?: number;
}

export function isEnabled(): boolean {
  const raw = (Deno.env.get('CASHBACK_BTC_ENABLED') ?? '').trim().toLowerCase();
  return raw === '1' || raw === 'true';
}

export async function handleRequest(req: Request): Promise<Response> {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  if (!isEnabled()) {
    return jsonResponse(
      {
        error: 'not_implemented',
        message:
          'Bitcoin conversion is not enabled. Set CASHBACK_BTC_ENABLED once a ' +
          'regulated provider integration and compliance sign-off are in place.',
      },
      501,
    );
  }

  // ---- Validation skeleton (only reached when the flag is on) ----
  let body: ConvertRequest;
  try {
    body = (await req.json()) as ConvertRequest;
  } catch {
    return errorResponse('Invalid JSON body');
  }

  const companyId = body.customer_company_id;
  const amount = Number(body.amount_ils);
  if (!companyId) {
    return errorResponse('customer_company_id is required');
  }
  if (!Number.isFinite(amount) || amount <= 0) {
    return errorResponse('amount_ils must be a positive number');
  }

  // Service client is available for the future implementation: verify the
  // available balance, call the regulated provider, then write a 'redeem' row
  // to cashback_ledger. Intentionally not wired up yet.
  getServiceClient();

  return jsonResponse(
    {
      error: 'not_implemented',
      message: 'Provider conversion flow is not implemented yet.',
    },
    501,
  );
}

if (import.meta.main) {
  serve(handleRequest);
}
