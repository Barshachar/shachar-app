import { describe, expect, test, beforeEach } from 'vitest';
import { canonical, productJsonLd } from '@/lib/seo';
import type { Product } from '@/lib/types';

describe('SEO helpers', () => {
  beforeEach(() => {
    process.env.NEXT_PUBLIC_SITE_URL = 'https://example.com';
  });

  test('canonical builds absolute URL', () => {
    expect(canonical('/product/x')).toBe('https://example.com/product/x');
  });

  test('product JSON-LD contains offer in ILS', () => {
    const product: Product = {
      id: 'p_test',
      name: 'ברז בדיקה',
      slug: 'test-faucet',
      sku: 'TF-001',
      brand: 'TestBrand',
      vendor_slug: 'testvendor',
      category_slug: 'plumbing',
      primary_image_url: '/images/p.png',
      description_html: '<p>תיאור</p>',
      is_active: true,
      created_at: '2024-01-01T00:00:00.000Z',
      variants: []
    };

    const ld = productJsonLd(product, {
      priceCents: 12900,
      image: 'https://example.com/images/p.png',
      brandLabel: 'TestBrand'
    });

    expect(ld['@type']).toBe('Product');
    expect(ld.offers.priceCurrency).toBe('ILS');
    expect(ld.offers.price).toBe('129.00');
  });
});
