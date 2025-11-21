import { NextResponse } from 'next/server';
import { updateOrderStatus } from '@/lib/data';
import { hasProcessedTransaction, markTransactionProcessed } from '@/lib/payments/cardcom-idempotency';
import { assertLocalMode } from '@/lib/local-mode';

function parseReturnData(value: string | null): string | null {
  if (!value) return null;
  const params = new URLSearchParams(value);
  return params.get('order_id');
}

function extractTransactionId(formData: FormData): string | null {
  const keys = ['TrxId', 'TransactionID', 'ResponseTrxId', 'ResponseTransactionID', 'transaction_id'];
  for (const key of keys) {
    const candidate = formData.get(key)?.toString();
    if (candidate) {
      return candidate;
    }
  }
  return null;
}

export async function POST(request: Request) {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const contentType = request.headers.get('content-type') || '';
  if (!contentType.includes('application/x-www-form-urlencoded') && !contentType.includes('multipart/form-data')) {
    return NextResponse.json({ error: 'Unsupported content type' }, { status: 415 });
  }

  const formData = await request.formData();
  const responseCode = formData.get('ResponseCode')?.toString();
  const returnDataRaw = formData.get('ReturnData')?.toString() ?? formData.get('ReturnData[order_id]')?.toString() ?? null;
  const orderId = parseReturnData(returnDataRaw) || formData.get('order_id')?.toString() || '';
  const transactionId = extractTransactionId(formData);

  if (!orderId) {
    return NextResponse.json({ error: 'Missing order_id' }, { status: 400 });
  }

  const status = responseCode === '0' ? 'paid' : 'failed';
  if (transactionId && hasProcessedTransaction(transactionId)) {
    return NextResponse.json({ ok: true, status, duplicate: true });
  }

  await updateOrderStatus(orderId, status);
  markTransactionProcessed(transactionId);

  return NextResponse.json({ ok: true, status });
}
