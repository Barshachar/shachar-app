import { describe, expect, it } from 'vitest';
import { parseCsv, upsertCatalog } from '@/lib/importer/local-import';
import type { Category, Product, ProductVariant } from '@/lib/types';

describe('local CSV importer', () => {
  const csv = `name,slug,sku,brand,category_slug,price_cents,primary_image_url,description_html\n` +
    `"ברז כיור בסיסי","basic-basin-faucet","FC-BS-001","Hamat","faucets",54900,"/placeholders/p0.png","<p>ברז בסיסי.</p>"\n` +
    `"צינור SP 16","sp-tube-16","SP-TU-016","SP Systems","sp-pex",1990,"",""`;

  it('parses CSV rows with required fields', () => {
    const result = parseCsv(csv);
    expect(result.errors).toHaveLength(0);
    expect(result.records.length).toBe(2);
    expect(result.records[0]).toMatchObject({ slug: 'basic-basin-faucet', price_cents: 54900 });
  });

  it('upserts catalog entries with deterministic ids', () => {
    const categories: Category[] = [];
    const products: Product[] = [];
    const variants: ProductVariant[] = [];

    const { records, errors } = parseCsv(csv);
    expect(errors).toHaveLength(0);
    const { categories: nextCategories, products: nextProducts, variants: nextVariants, summary } = upsertCatalog(
      records,
      categories,
      products,
      variants
    );

    expect(summary.categories.added).toBeGreaterThan(0);
    expect(nextCategories.some((category) => category.slug === 'faucets' && category.id === 'cat-faucets')).toBe(true);
    expect(nextProducts.some((product) => product.id === 'p_basic-basin-faucet')).toBe(true);
    const variant = nextVariants.find((item) => item.product_id === 'p_basic-basin-faucet');
    expect(variant).toBeDefined();
    expect(variant?.id).toBe('v_basic-basin-faucet_default');
    expect(variant?.price_cents).toBe(54900);
  });
});
