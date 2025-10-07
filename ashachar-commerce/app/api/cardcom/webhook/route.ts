import { NextResponse } from 'next/server';
import { updateOrderStatus } from '@/lib/data';

function parseReturnData(value: string | null): string | null {
  if (!value) return null;
  const params = new URLSearchParams(value);
  return params.get('order_id');
}

export async function POST(request: Request) {
  const contentType = request.headers.get('content-type') || '';
  if (!contentType.includes('application/x-www-form-urlencoded') && !contentType.includes('multipart/form-data')) {
    return NextResponse.json({ error: 'Unsupported content type' }, { status: 415 });
  }

  const formData = await request.formData();
  const responseCode = formData.get('ResponseCode')?.toString();
  const returnDataRaw = formData.get('ReturnData')?.toString() ?? formData.get('ReturnData[order_id]')?.toString() ?? null;
  const orderId = parseReturnData(returnDataRaw) || formData.get('order_id')?.toString() || '';

  if (!orderId) {
    return NextResponse.json({ error: 'Missing order_id' }, { status: 400 });
  }

  const status = responseCode === '0' ? 'paid' : 'failed';
  await updateOrderStatus(orderId, status);

  return NextResponse.json({ ok: true, status });
}
