import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

export type CsvRow = {
  vendor_company_id: string;
  product_variant_id: string;
  price_cents: number;
  currency: string;
  qty_tier?: number;
};

export type RpcResult = { data: unknown; error: { message?: string } | null };
export type SupabaseLike = {
  rpc: (fn: string, args: Record<string, unknown>) => Promise<RpcResult>;
};

const ALLOWED_CURRENCIES = new Set(['ILS', 'USD', 'EUR']);

function normalizeIntString(value?: string) {
  return value?.replace(/[,_\s]/g, '');
}

export function toCsvRow(rec: Record<string, string>): CsvRow {
  const vendor = rec.vendor_company_id?.trim();
  const variant = rec.product_variant_id?.trim();
  const priceRaw = normalizeIntString(rec.price_cents?.trim());
  const currency = (rec.currency ?? 'ILS').trim().toUpperCase();
  const qtyRaw = normalizeIntString(rec.qty_tier?.trim());

  if (!vendor || !variant || !priceRaw) {
    throw new TypeError(`Invalid CSV row: ${JSON.stringify(rec)}`);
  }
  if (!ALLOWED_CURRENCIES.has(currency)) {
    throw new TypeError(`Invalid currency: ${currency}`);
  }

  const price = Number(priceRaw);
  if (!Number.isInteger(price)) {
    throw new TypeError(`Invalid price_cents: ${priceRaw}`);
  }

  const qty = qtyRaw ? Number(qtyRaw) : undefined;
  if (qtyRaw && !Number.isInteger(qty!)) {
    throw new TypeError(`Invalid qty_tier: ${qtyRaw}`);
  }

  return {
    vendor_company_id: vendor,
    product_variant_id: variant,
    price_cents: price,
    currency,
    ...(qty !== undefined ? { qty_tier: qty } : {}),
  };
}

export function parseCsv(text: string): Array<Record<string, string>> {
  const lines = text.split(/\r?\n/).filter(Boolean);
  const [header, ...rows] = lines;
  if (!header) {
    return [];
  }
  const headers = header.split(',').map((h) => h.trim());
  return rows.map((row) => {
    const cells = row.split(',').map((c) => c.trim());
    const record: Record<string, string> = {};
    headers.forEach((key, index) => {
      record[key] = cells[index] ?? '';
    });
    return record;
  });
}

export async function importPriceList(
  client: SupabaseLike,
  rows: Array<Record<string, string>>
): Promise<void> {
  for (const raw of rows) {
    const row = toCsvRow(raw);
    const { error } = await client.rpc('rpc_upsert_prices', { row });
    if (error) {
      throw new Error(error.message ?? 'rpc_upsert_prices failed');
    }
  }
}

export async function handler(
  req: Request,
  client?: SupabaseLike
): Promise<Response> {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  try {
    const jwt = decodeJwtWithoutVerify(req.headers.get('authorization'));
    const contentType = req.headers.get('content-type') ?? '';
    let rawRows: Array<Record<string, string>> = [];
    if (contentType.includes('application/json')) {
      const body = (await req.json()) as {
        rows?: Array<Record<string, string>>;
      };
      if (!body.rows || !Array.isArray(body.rows)) {
        throw new TypeError('missing rows');
      }
      rawRows = body.rows;
    } else {
      return errorResponse('unsupported content-type', 415);
    }
    if (rawRows.length === 0) {
      return jsonResponse({ ok: true, imported: 0 });
    }
    for (const record of rawRows) {
      const vendor = (record.vendor_company_id ?? record.vendorId ?? record.company_id ?? '').trim();
      if (!vendor) {
        throw new TypeError('Invalid CSV row: missing vendor_company_id');
      }
      requireSameCompanyOrAdmin(jwt as JwtLike | null, vendor);
    }
    const rpcClient =
      client ??
      (() => {
        const svc = getServiceClient();
        return {
          rpc: (fn, args) => svc.rpc(fn, args) as unknown as Promise<RpcResult>,
        };
      })();
    await importPriceList(rpcClient, rawRows);
    return jsonResponse({ ok: true, imported: rawRows.length });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'bad request';
    const isValidation =
      error instanceof TypeError ||
      /Invalid (CSV row|price_cents|qty_tier)/i.test(message) ||
      /missing rows/i.test(message) ||
      message.startsWith('forbidden');
    const status = isValidation ? (message.startsWith('forbidden') ? 403 : 400) : 500;
    return errorResponse(message, status);
  }
}

if (import.meta.main) {
  serve((req) => handler(req));
}
function base64UrlDecode(value: string): string {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const pad = normalized.length % 4 === 2 ? '==' : normalized.length % 4 === 3 ? '=' : '';
  return atob(normalized + pad);
}

export function decodeJwtWithoutVerify(authHeader: string | null): Record<string, unknown> | null {
  if (!authHeader?.toLowerCase().startsWith('bearer ')) {
    return null;
  }
  const token = authHeader.slice(7).trim();
  const parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }
  try {
    return JSON.parse(base64UrlDecode(parts[1]));
  } catch (_error) {
    return null;
  }
}

type JwtLike = {
  app_metadata?: {
    company_id?: string;
    roles?: string[];
  };
};

function isSystemAdmin(jwt: JwtLike | null | undefined): boolean {
  const roles = jwt?.app_metadata?.roles ?? [];
  return roles.includes('system_admin');
}

function requireSameCompanyOrAdmin(jwt: JwtLike | null | undefined, vendorCompanyId: string): void {
  if (isSystemAdmin(jwt)) {
    return;
  }
  const companyId = jwt?.app_metadata?.company_id;
  if (!companyId || companyId !== vendorCompanyId) {
    throw new Error('forbidden: vendor_company_id does not match caller company');
  }
}
