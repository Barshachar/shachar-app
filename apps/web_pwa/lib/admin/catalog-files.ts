import { promises as fs } from 'node:fs';
import path from 'node:path';
import type { Product, ProductVariant, Category } from '@/lib/types';

export const DATA_DIR = path.join(process.cwd(), 'data');
export const PRODUCTS_PATH = path.join(DATA_DIR, 'products.json');
export const VARIANTS_PATH = path.join(DATA_DIR, 'variants.json');
export const CATEGORIES_PATH = path.join(DATA_DIR, 'categories.json');
export const BACKUP_DIR = path.join(DATA_DIR, 'backup');

export async function readJson<T>(filePath: string, fallback: T): Promise<T> {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    return JSON.parse(content) as T;
  } catch (error: any) {
    if (error?.code === 'ENOENT') {
      return fallback;
    }
    throw error;
  }
}

export async function writeJson<T>(filePath: string, data: T): Promise<void> {
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
}

export async function backupFile(filePath: string): Promise<string | null> {
  try {
    await fs.access(filePath);
  } catch (error: any) {
    if (error?.code === 'ENOENT') {
      return null;
    }
    throw error;
  }
  await fs.mkdir(BACKUP_DIR, { recursive: true });
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const fileName = path.basename(filePath);
  const target = path.join(BACKUP_DIR, `${stamp}-${fileName}`);
  await fs.copyFile(filePath, target);
  return path.relative(DATA_DIR, target);
}

export async function backupCatalogFiles(): Promise<string[]> {
  const results = await Promise.all([
    backupFile(PRODUCTS_PATH),
    backupFile(VARIANTS_PATH),
    backupFile(CATEGORIES_PATH)
  ]);
  return results.filter(Boolean) as string[];
}

export function sortProducts(products: Product[]): Product[] {
  return [...products].sort((a, b) => a.slug.localeCompare(b.slug));
}

export function sortVariants(variants: ProductVariant[]): ProductVariant[] {
  return [...variants].sort((a, b) => a.id.localeCompare(b.id));
}

export function sortCategories(categories: Category[]): Category[] {
  return [...categories].sort((a, b) => a.slug.localeCompare(b.slug));
}

export async function loadCatalog() {
  const [products, variants, categories] = await Promise.all([
    readJson<Product[]>(PRODUCTS_PATH, []),
    readJson<ProductVariant[]>(VARIANTS_PATH, []),
    readJson<Category[]>(CATEGORIES_PATH, [])
  ]);
  return { products, variants, categories };
}

export async function saveCatalog({
  products,
  variants,
  categories
}: {
  products: Product[];
  variants: ProductVariant[];
  categories: Category[];
}) {
  await backupCatalogFiles();
  await Promise.all([
    writeJson(PRODUCTS_PATH, sortProducts(products)),
    writeJson(VARIANTS_PATH, sortVariants(variants)),
    writeJson(CATEGORIES_PATH, sortCategories(categories))
  ]);
}

export function ensureCategory(categories: Category[], categorySlug: string): Category[] {
  const existing = categories.find((item) => item.slug === categorySlug);
  if (existing) {
    return categories;
  }
  const category: Category = {
    id: categories.find((item) => item.slug === categorySlug)?.id ?? `cat-${categorySlug}`,
    name: categorySlug
      .split(/[-_]+/)
      .filter(Boolean)
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' '),
    slug: categorySlug,
    image_url: `/categories/${categorySlug}.png`,
    parent_id: null
  };
  return [...categories, category];
}

export function vendorSlug(brand?: string | null): string {
  const value = (brand ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  return value || 'local-vendor';
}
