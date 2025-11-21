import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import type { NextRequest } from 'next/server';
import { GET as cartGet } from '@/app/api/cart/route';
import { POST as cartAdd } from '@/app/api/cart/add/route';
import { POST as cartUpdate } from '@/app/api/cart/update/route';
import { POST as cartRemove } from '@/app/api/cart/remove/route';
import { POST as cartClear } from '@/app/api/cart/clear/route';
import { POST as checkoutPost } from '@/app/api/checkout/route';
import { POST as cardcomWebhook } from '@/app/api/cardcom/webhook/route';
import { GET as skuMapGet } from '@/app/api/catalog/sku-map/route';
import { POST as quotePost } from '@/app/api/quote/route';
import { POST as logErrorPost } from '@/app/api/log-error/route';
import { GET as cartOgGet } from '@/app/api/og/route';
import { DEFAULT_LOCAL_MODE_MESSAGE, LOCAL_MODE_CODE } from '@/lib/local-mode';

type Handler = () => Promise<Response>;

function makeRequest(path: string, init?: RequestInit): Request {
  return new Request(`http://localhost${path}`, {
    method: init?.method ?? 'POST',
    headers: init?.headers,
    body: init?.body
  });
}

function makeNextRequest(url: string, overrides?: Partial<NextRequest>): NextRequest {
  return {
    nextUrl: new URL(url),
    method: overrides?.method ?? 'GET',
    headers: overrides?.headers ?? new Headers(),
    cookies: overrides?.cookies ?? { get: () => undefined },
    json: overrides?.json ?? (async () => ({})),
    ...overrides
  } as NextRequest;
}

const originalAppDataMode = process.env.APP_DATA_MODE;
const expectedError = { error: { code: LOCAL_MODE_CODE, message: DEFAULT_LOCAL_MODE_MESSAGE } };

describe('buyer APIs enforce local-only mode', () => {
  beforeEach(() => {
    process.env.APP_DATA_MODE = 'remote';
  });

  afterEach(() => {
    if (originalAppDataMode === undefined) {
      delete process.env.APP_DATA_MODE;
    } else {
      process.env.APP_DATA_MODE = originalAppDataMode;
    }
  });

  const cases: { name: string; handler: Handler }[] = [
    {
      name: 'cart GET',
      handler: () => cartGet(makeNextRequest('http://localhost/api/cart'))
    },
    {
      name: 'cart add POST',
      handler: () => cartAdd(makeRequest('/api/cart/add', { body: JSON.stringify({}), headers: { 'Content-Type': 'application/json' } }))
    },
    {
      name: 'cart update POST',
      handler: () => cartUpdate(makeRequest('/api/cart/update', { body: JSON.stringify({}), headers: { 'Content-Type': 'application/json' } }))
    },
    {
      name: 'cart remove POST',
      handler: () => cartRemove(makeRequest('/api/cart/remove', { body: JSON.stringify({}), headers: { 'Content-Type': 'application/json' } }))
    },
    {
      name: 'cart clear POST',
      handler: () => cartClear()
    },
    {
      name: 'checkout POST',
      handler: () => checkoutPost()
    },
    {
      name: 'cardcom webhook POST',
      handler: () =>
        cardcomWebhook(
          makeRequest('/api/cardcom/webhook', {
            method: 'POST',
            body: '',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
          })
        )
    },
    {
      name: 'catalog sku map GET',
      handler: () => skuMapGet()
    },
    {
      name: 'quote POST',
      handler: () => quotePost(makeRequest('/api/quote', { method: 'POST', body: '' }))
    },
    {
      name: 'log-error POST',
      handler: () =>
        logErrorPost(
          makeNextRequest('http://localhost/api/log-error', {
            method: 'POST'
          })
        )
    },
    {
      name: 'OG image GET',
      handler: () => cartOgGet(makeRequest('/api/og', { method: 'GET' }))
    }
  ];

  cases.forEach(({ name, handler }) => {
    it(`${name} returns 503 when APP_DATA_MODE !== 'local'`, async () => {
      const response = await handler();
      expect(response.status).toBe(503);
      expect(response.headers.get('content-type')).toContain('application/json');
      const body = await response.json();
      expect(body).toEqual(expectedError);
    });
  });
});
