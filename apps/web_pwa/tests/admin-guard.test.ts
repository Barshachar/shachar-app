import { describe, expect, test, afterEach } from 'vitest';
import type { NextRequest } from 'next/server';
import { guardAdminApiRequest } from '@/lib/admin/guard';
import { POST, DELETE } from '@/app/api/admin/catalog/route';

function makeRequest({
  url,
  cookie,
  body
}: {
  url: string;
  cookie?: string;
  body?: any;
}): NextRequest {
  const requestLike = {
    url,
    cookies: {
      get: (name: string) => (cookie && name === 'admin_pin' ? { value: cookie } : undefined)
    },
    json: body ? async () => body : async () => ({})
  } as Partial<NextRequest>;
  return requestLike as NextRequest;
}

const originalPin = process.env.ADMIN_PIN;
const originalReadonly = process.env.ADMIN_READONLY;

afterEach(() => {
  if (originalPin === undefined) {
    delete process.env.ADMIN_PIN;
  } else {
    process.env.ADMIN_PIN = originalPin;
  }
  if (originalReadonly === undefined) {
    delete process.env.ADMIN_READONLY;
  } else {
    process.env.ADMIN_READONLY = originalReadonly;
  }
});

describe('admin guard', () => {
  test('returns 403 when ADMIN_PIN missing', () => {
    delete process.env.ADMIN_PIN;
    const response = guardAdminApiRequest(makeRequest({ url: 'http://localhost/admin/catalog' }));
    expect(response).not.toBeNull();
    expect(response?.status).toBe(403);
  });

  test('returns 403 when cookie invalid', () => {
    process.env.ADMIN_PIN = '1234';
    const response = guardAdminApiRequest(
      makeRequest({ url: 'http://localhost/admin/catalog', cookie: 'wrong' })
    );
    expect(response).not.toBeNull();
    expect(response?.status).toBe(403);
  });
});

describe('read-only mode', () => {
  test('POST denies writes when ADMIN_READONLY=1', async () => {
    process.env.ADMIN_PIN = '1234';
    process.env.ADMIN_READONLY = '1';
    const response = await POST(
      makeRequest({
        url: 'http://localhost/api/admin/catalog',
        cookie: '1234',
        body: { action: 'upsert', product: { slug: 'demo', name: 'Demo', price_cents: 100, category_slug: 'general' } }
      })
    );
    expect(response.status).toBe(403);
  });

  test('DELETE denies writes when ADMIN_READONLY=1', async () => {
    process.env.ADMIN_PIN = '1234';
    process.env.ADMIN_READONLY = '1';
    const response = await DELETE(
      makeRequest({ url: 'http://localhost/api/admin/catalog?slug=demo', cookie: '1234' })
    );
    expect(response.status).toBe(403);
  });
});
