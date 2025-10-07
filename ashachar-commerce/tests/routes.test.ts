import { describe, expect, test, beforeAll } from 'vitest';
import robots from '@/app/robots';
import sitemap from '@/app/sitemap';

beforeAll(() => {
  process.env.NEXT_PUBLIC_SITE_URL = 'https://example.com';
});

describe('Route generators', () => {
  test('robots disallows admin paths', () => {
    const rules = robots();
    expect(rules.rules).toBeDefined();
    const disallow = Array.isArray(rules.rules) ? rules.rules[0].disallow : rules.rules.disallow;
    expect(disallow).toContain('/admin');
  });

  test('sitemap includes urls', async () => {
    const urls = await sitemap();
    expect(Array.isArray(urls)).toBe(true);
    expect(urls.length).toBeGreaterThan(0);
    const first = urls[0];
    expect(first.url).toMatch(/^https?:\/\//);
  });
});
