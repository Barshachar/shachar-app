import { afterEach, beforeEach, describe, expect, test, vi } from 'vitest';
import { POST } from '@/app/api/quote/route';
import * as dataModule from '@/lib/data';
import type { CartItem } from '@/lib/types';

const ORIGINAL_MODE = process.env.APP_DATA_MODE;

beforeEach(() => {
  process.env.APP_DATA_MODE = 'local';
});

afterEach(() => {
  if (ORIGINAL_MODE === undefined) {
    delete process.env.APP_DATA_MODE;
  } else {
    process.env.APP_DATA_MODE = ORIGINAL_MODE;
  }
  vi.restoreAllMocks();
});

describe('POST /api/quote', () => {
  test('returns a PDF attachment for populated cart', async () => {
    const sampleItems: CartItem[] = [
      {
        id: 'line-1',
        cart_id: 'cart-1',
        variant_id: 'variant-1',
        qty: 2,
        variant: {
          id: 'variant-1',
          product_id: 'product-1',
          name: 'ברז נחושת',
          sku: 'SKU-1',
          price_cents: 12900,
          currency: 'ILS',
          barcode: null,
          variant_prices: null
        },
        product: {
          id: 'product-1',
          name: 'ברז נחושת מקצועי',
          primary_image_url: null,
          vendor_slug: 'ashachar'
        }
      }
    ];

    const fetchSpy = vi.spyOn(dataModule, 'fetchCartItems').mockResolvedValue(sampleItems);

    const request = new Request('http://localhost/api/quote', {
      method: 'POST',
      headers: {
        cookie: 'ashachar_sid=test-session'
      }
    });

    const response = await POST(request);

    expect(fetchSpy).toHaveBeenCalledWith('test-session');
    expect(response.status).toBe(200);
    const contentType = response.headers.get('Content-Type');
    expect(contentType).toBeTruthy();
    expect(contentType?.startsWith('application/pdf')).toBe(true);
    const payload = await response.arrayBuffer();
    expect(payload.byteLength).toBeGreaterThan(500);
  });

  test('normalizes numeric cart fields before computing totals', async () => {
    const sampleItems: CartItem[] = [
      {
        id: 'line-1',
        cart_id: 'cart-1',
        variant_id: 'variant-1',
        qty: '2.5' as unknown as number,
        variant: {
          id: 'variant-1',
          product_id: 'product-1',
          name: 'ברז פלדה',
          sku: 'SKU-1',
          price_cents: '12900' as unknown as number,
          currency: 'ILS',
          barcode: null,
          variant_prices: null
        },
        product: {
          id: 'product-1',
          name: 'ברז פלדה מקצועי',
          primary_image_url: null,
          vendor_slug: 'ashachar'
        }
      },
      {
        id: 'line-2',
        cart_id: 'cart-1',
        variant_id: 'variant-2',
        qty: '1' as unknown as number,
        variant: {
          id: 'variant-2',
          product_id: 'product-2',
          name: 'אטם',
          sku: 'SKU-2',
          price_cents: '3300' as unknown as number,
          currency: 'ILS',
          barcode: null,
          variant_prices: null
        },
        product: {
          id: 'product-2',
          name: 'אטם איכותי',
          primary_image_url: null,
          vendor_slug: 'ashachar'
        }
      }
    ];

    const fetchSpy = vi.spyOn(dataModule, 'fetchCartItems').mockResolvedValue(sampleItems);

    const request = new Request('http://localhost/api/quote', {
      method: 'POST',
      headers: {
        cookie: 'ashachar_sid=test-session'
      }
    });

    const response = await POST(request);

    expect(fetchSpy).toHaveBeenCalledWith('test-session');
    expect(response.status).toBe(200);
    const contentType = response.headers.get('Content-Type');
    expect(contentType?.startsWith('application/pdf')).toBe(true);
    const payload = await response.arrayBuffer();
    expect(payload.byteLength).toBeGreaterThan(500);
  });
});
