import { describe, expect, it } from 'vitest';
import {
  getLocalCategories,
  getLocalProductsForCategory,
  filterLocalProducts,
  findLocalVariantBySku
} from '@/lib/local-store';

describe('local data provider', () => {
  it('loads categories with expected breadth', async () => {
    const categories = await getLocalCategories();
    expect(categories.length).toBeGreaterThanOrEqual(12);
  });

  it('filters products by brand within category', async () => {
    const faucets = await getLocalProductsForCategory('faucets');
    const filtered = filterLocalProducts(faucets, { brands: ['Hamat'] });
    expect(filtered.length).toBeGreaterThan(0);
    expect(filtered.every((product) => product.brand === 'Hamat')).toBe(true);
  });

  it('resolves SKU to variant id', async () => {
    const result = await findLocalVariantBySku('FC-PO-PR-DEF');
    expect(result).not.toBeNull();
    expect(result?.variant.id).toMatch(/(var|v)[-_]pullout-faucet-pro/);
  });
});
