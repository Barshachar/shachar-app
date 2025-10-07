import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { getServiceClient, jsonResponse, errorResponse } from '../_shared/client.ts';

function toCsv(rows: Array<Record<string, unknown>>): string {
  if (!rows.length) {
    return 'order_number,total,status,created_at';
  }
  const header = 'order_number,total,status,created_at';
  const body = rows
    .map((row) => [
      row.order_number,
      row.total,
      row.status,
      row.created_at,
    ]
      .map((value) => `${value ?? ''}`.replace(/"/g, '""'))
      .map((value) => value.includes(',') ? `"${value}"` : value)
      .join(','))
    .join('\n');
  return `${header}\n${body}`;
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return errorResponse('Use POST', 405);
  }

  const payload = await req.json();
  const { from_date, to_date, format = 'pdf' } = payload ?? {};
  const supabase = getServiceClient();

  const { data, error } = await supabase
    .from('orders')
    .select('order_number, total, status, created_at')
    .gte('created_at', from_date ?? '1970-01-01')
    .lte('created_at', to_date ?? new Date().toISOString());

  if (error) {
    return errorResponse(error.message, 500);
  }

  const isCsv = String(format).toLowerCase() === 'csv';
  const extension = isCsv ? 'csv' : 'json';
  const contentType = isCsv ? 'text/csv' : 'application/json';
  const body = isCsv ? toCsv(data ?? []) : JSON.stringify({ format: extension, rows: data }, null, 2);
  const filename = `reports/report-${Date.now()}.${extension}`;

  const { error: storageError } = await supabase.storage
    .from('attachments')
    .upload(filename, new Blob([body], { type: contentType }), {
      upsert: true,
    });

  if (storageError) {
    return errorResponse(storageError.message, 500);
  }

  const { data: signed, error: signedError } = await supabase.storage
    .from('attachments')
    .createSignedUrl(filename, 60 * 60);

  if (signedError) {
    return errorResponse(signedError.message, 500);
  }

  return jsonResponse({
    filename,
    signed_url: signed?.signedUrl,
    format: extension,
  });
});
