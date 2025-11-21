import { describe, it, expect, beforeEach, vi } from 'vitest';
import { POST as cardcomWebhook } from '@/app/api/cardcom/webhook/route';
import * as dataModule from '@/lib/data';
import { resetProcessedTransactions } from '@/lib/payments/cardcom-idempotency';

function buildRequest(body: URLSearchParams) {
  return new Request('http://localhost/app/api/cardcom/webhook', {
    method: 'POST',
    headers: {
      'content-type': 'application/x-www-form-urlencoded'
    },
    body
  });
}

describe('cardcom webhook idempotency', () => {
  beforeEach(() => {
    resetProcessedTransactions();
    vi.restoreAllMocks();
  });

  it('applies status only once per transaction id', async () => {
    const spy = vi.spyOn(dataModule, 'updateOrderStatus').mockResolvedValue();
    const params = new URLSearchParams({
      ResponseCode: '0',
      order_id: 'local-order-123',
      TrxId: 'trx-2001'
    });

    const first = await cardcomWebhook(buildRequest(params));
    const second = await cardcomWebhook(buildRequest(params));

    expect(first.status).toBe(200);
    expect(second.status).toBe(200);
    expect(await first.json()).toMatchObject({ ok: true, status: 'paid' });
    expect(await second.json()).toMatchObject({ ok: true, duplicate: true });
    expect(spy).toHaveBeenCalledTimes(1);
    expect(spy).toHaveBeenCalledWith('local-order-123', 'paid');
  });
});
