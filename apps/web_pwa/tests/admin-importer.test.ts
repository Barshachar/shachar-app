import { afterEach, describe, expect, test } from 'vitest';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { applyLocalCatalogImport } from '@/lib/importer/apply-local-import';

const tempDirs: string[] = [];

afterEach(async () => {
  await Promise.all(tempDirs.splice(0).map((dir) => fs.rm(dir, { recursive: true, force: true })));
});

async function createTempDataDir() {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'catalog-test-'));
  tempDirs.push(dir);
  await fs.mkdir(path.join(dir, 'backup')); // ensure backup dir exists for assertions
  await fs.writeFile(
    path.join(dir, 'categories.json'),
    JSON.stringify([
      { id: 'cat-plumbing', name: 'Plumbing', slug: 'plumbing', image_url: null, parent_id: null }
    ])
  );
  await fs.writeFile(
    path.join(dir, 'products.json'),
    JSON.stringify([
      {
        id: 'p_copper-pipe',
        name: 'צינור ישן',
        slug: 'copper-pipe',
        sku: 'OLD-PIPE',
        brand: 'Huliot',
        vendor_slug: 'huliot',
        category_slug: 'plumbing',
        primary_image_url: '/old.png',
        description_html: '<p>ישן</p>',
        is_active: true,
        created_at: '2024-01-01T00:00:00.000Z'
      }
    ])
  );
  await fs.writeFile(
    path.join(dir, 'variants.json'),
    JSON.stringify([
      {
        id: 'v_copper-pipe_default',
        product_id: 'p_copper-pipe',
        name: 'ברירת מחדל',
        sku: 'OLD-PIPE-DEF',
        price_cents: 1000,
        currency: 'ILS',
        barcode: null,
        variant_prices: null
      }
    ])
  );
  return dir;
}

describe('applyLocalCatalogImport', () => {
  test('merges CSV catalog into local JSON files', async () => {
    const dir = await createTempDataDir();
    const csv = [
      'name,slug,sku,brand,category_slug,price_cents,primary_image_url,description_html',
      'צינור חדש,new-copper,NEW-PIPE,Huliot,plumbing,12900,/pipes/new.png,<p>צינור חדש</p>',
      'צינור ישן,copper-pipe,OLD-PIPE,Huliot,plumbing,9900,/pipes/old.png,<p>עודכן</p>'
    ].join('\n');

    const result = await applyLocalCatalogImport(csv, dir);

    expect(result.errors).toHaveLength(0);
    expect(result.summary.products.added).toBe(1);
    expect(result.summary.products.updated).toBe(1);
    expect(result.counts.products).toBe(2);

    const productsRaw = await fs.readFile(path.join(dir, 'products.json'), 'utf8');
    const products = JSON.parse(productsRaw);
    const newProduct = products.find((item: any) => item.slug === 'new-copper');
    expect(newProduct).toMatchObject({
      name: 'צינור חדש',
      sku: 'NEW-PIPE',
      created_at: expect.any(String)
    });
    const updatedProduct = products.find((item: any) => item.slug === 'copper-pipe');
    expect(updatedProduct).toBeDefined();
    expect(updatedProduct).toMatchObject({
      name: 'צינור ישן',
      primary_image_url: '/pipes/old.png',
      created_at: '2024-01-01T00:00:00.000Z'
    });

    const variantsRaw = await fs.readFile(path.join(dir, 'variants.json'), 'utf8');
    const variants = JSON.parse(variantsRaw);
    const defaultVariant = variants.find((item: any) => item.product_id === updatedProduct!.id);
    expect(defaultVariant.price_cents).toBe(9900);

    const backupFiles = await fs.readdir(path.join(dir, 'backup'));
    expect(backupFiles.length).toBeGreaterThanOrEqual(3);
  });

  test('supports supplier CSV headers and slugifies Hebrew values', async () => {
    const dir = await createTempDataDir();
    const csv = [
      'שם מוצר,מקט,מותג,קטגוריה,מחיר (₪),תמונה,תיאור',
      'ברז יוקרתי,BZ-123,חמת,ברזים,299.90,https://cdn.example.com/tap.jpg,<p>ברז יוקרה</p>',
      'מפצל צנרת,MF-001,פלסאון,אביזרי צנרת,"1,234.50",,',
      'חסר מחיר,NM-000,מותג,קטגוריה,,,'
    ].join('\n');

    const result = await applyLocalCatalogImport(csv, dir);

    expect(result.records.length).toBe(2);
    expect(result.errors.length).toBe(1);
    expect(result.errors[0].message).toContain('מחיר');

    const productsRaw = await fs.readFile(path.join(dir, 'products.json'), 'utf8');
    const products = JSON.parse(productsRaw);
    const luxuryTap = products.find((item: any) => item.sku === 'BZ-123');
    expect(luxuryTap).toBeDefined();
    expect(luxuryTap.slug).toMatch(/^brz-[a-z0-9-]+$/);
    expect(luxuryTap.category_slug).toMatch(/^[a-z0-9-]+$/);

    const adapter = products.find((item: any) => item.sku === 'MF-001');
    expect(adapter).toBeDefined();
    const adapterSlug = adapter.slug;

    const variantsRaw = await fs.readFile(path.join(dir, 'variants.json'), 'utf8');
    const variants = JSON.parse(variantsRaw);
    const adapterVariant = variants.find((item: any) => item.product_id === `p_${adapterSlug}`);
    expect(adapterVariant).toBeDefined();
    expect(adapterVariant.price_cents).toBe(123450);
  });
});
