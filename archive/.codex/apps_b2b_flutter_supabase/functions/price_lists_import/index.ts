import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

interface CsvRow {
  variant_id: string;
  unit_price: string;
  min_qty?: string;
  scope?: string;
  customer_id?: string;
  currency?: string;
}

function parseCsv(text: string): CsvRow[] {
  const lines = text.split(/\r?\n/).filter(Boolean);
  const [header, ...rows] = lines;
  const headers = header.split(',').map((h) => h.trim());
  return rows.map((row) => {
    const cells = row.split(',').map((c) => c.trim());
    const record: Record<string, string> = {};
    headers.forEach((key, index) => {
      record[key] = cells[index] ?? '';
    });
    return record as CsvRow;
  });
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  const supabase = getServiceClient();
  const contentType = req.headers.get('content-type') ?? '';
  let vendorId: string | undefined;
  let rows: CsvRow[] = [];

  if (contentType.includes('application/json')) {
    const body = await req.json();
    vendorId = body?.vendor_id as string | undefined;
    if (Array.isArray(body?.rows)) {
      rows = body.rows as CsvRow[];
    } else if (typeof body?.csv === 'string') {
      rows = parseCsv(body.csv as string);
    }
    if (!vendorId || rows.length === 0) {
      return errorResponse('vendor_id and CSV content are required');
    }
  } else {
    const formData = await req.formData();
    vendorId = formData.get('vendor_id')?.toString();
    const file = formData.get('file') as File | null;

    if (!vendorId || !file) {
      return errorResponse('vendor_id and CSV file are required');
    }

    const csvText = await file.text();
    rows = parseCsv(csvText);
    if (rows.length === 0) {
      return errorResponse('No rows found in CSV');
    }
  }

  const { data, error } = await supabase.rpc('rpc_upsert_prices', {
    p_vendor: vendorId,
    p_rows: rows,
  });

  if (error) {
    return errorResponse(error.message, 500);
  }

  return jsonResponse({ inserted: data });
});
