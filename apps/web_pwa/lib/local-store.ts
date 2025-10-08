import { promises as fs } from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import type { CartItem, Category, Product, ProductVariant, Vendor } from '@/lib/types';

const DATA_DIR = path.join(process.cwd(), 'data');

async function readJson<T>(file: string, fallback: T): Promise<T> {
  try {
    const content = await fs.readFile(path.join(DATA_DIR, file), 'utf8');
    return JSON.parse(content) as T;
  } catch (error: any) {
    if (error.code === 'ENOENT') {
      await writeJson(file, fallback);
      return fallback;
    }
    throw error;
  }
}

async function writeJson<T>(file: string, data: T): Promise<void> {
  await fs.mkdir(DATA_DIR, { recursive: true });
  await fs.writeFile(path.join(DATA_DIR, file), JSON.stringify(data, null, 2), 'utf8');
}

export function shouldUseLocalData(): boolean {
  return true;
}

export async function getLocalCategories(): Promise<Category[]> {
  return readJson<Category[]>('categories.json', []);
}

export async function getLocalVendors(): Promise<Vendor[]> {
  return readJson<Vendor[]>('vendors.json', []);
}

type ProductRecord = Omit<Product, 'variants'>;

function fallbackCreatedAt(index: number): string {
  const base = new Date('2024-01-01T00:00:00.000Z');
  base.setMinutes(base.getMinutes() + index);
  return base.toISOString();
}

function normalizeCreatedAt(value: string | null | undefined, index: number): string {
  if (value) {
    const timestamp = Date.parse(value);
    if (!Number.isNaN(timestamp)) {
      return new Date(timestamp).toISOString();
    }
  }
  return fallbackCreatedAt(index);
}

export async function getLocalProducts(): Promise<Product[]> {
  const [products, variants] = await Promise.all([
    readJson<ProductRecord[]>('products.json', []),
    readJson<ProductVariant[]>('variants.json', [])
  ]);
  const variantMap = new Map<string, ProductVariant[]>();
  for (const variant of variants) {
    const bucket = variantMap.get(variant.product_id) ?? [];
    bucket.push(variant);
    variantMap.set(variant.product_id, bucket);
  }
  return products.map((product, index) => ({
    ...product,
    created_at: normalizeCreatedAt(product.created_at, index),
    variants: variantMap.get(product.id) ?? []
  }));
}

export async function getLocalHeroProducts(): Promise<Product[]> {
  return getLocalNewestProducts(8);
}

export async function getLocalNewestProducts(limit = 8): Promise<Product[]> {
  const products = await getLocalProducts();
  const sorted = [...products]
    .filter((product) => product.is_active !== false)
    .sort((a, b) => {
      const aTime = Date.parse(a.created_at ?? '') || 0;
      const bTime = Date.parse(b.created_at ?? '') || 0;
      return bTime - aTime;
    });
  return sorted.slice(0, limit);
}

export async function getLocalCategoryWithProducts(slug: string): Promise<{
  category: Category | null;
  products: Product[];
}> {
  const [categories, products] = await Promise.all([getLocalCategories(), getLocalProducts()]);
  const category = categories.find((item) => item.slug === slug) ?? null;
  const relatedProducts = category
    ? products.filter((product) => product.category_slug === category.slug && product.is_active !== false)
    : [];
  return { category, products: relatedProducts };
}

export async function getLocalProductBySlug(slug: string): Promise<Product | null> {
  const products = await getLocalProducts();
  return products.find((product) => product.slug === slug) ?? null;
}

type LocalCartItemRecord = {
  id: string;
  variant_id: string;
  qty: number;
};

type LocalCartRecord = {
  id: string;
  session_id: string;
  items: LocalCartItemRecord[];
};

type LocalOrderRecord = {
  id: string;
  session_id: string;
  total_cents: number;
  status: 'pending' | 'paid' | 'failed';
  created_at: string;
  payment_ref?: string | null;
};

async function readCarts(): Promise<LocalCartRecord[]> {
  return readJson<LocalCartRecord[]>('carts.json', []);
}

async function writeCarts(carts: LocalCartRecord[]): Promise<void> {
  await writeJson('carts.json', carts);
}

export async function ensureLocalCart(sessionId: string): Promise<string> {
  const carts = await readCarts();
  const existing = carts.find((cart) => cart.session_id === sessionId);
  if (existing) {
    return existing.id;
  }
  const newCart: LocalCartRecord = {
    id: randomUUID(),
    session_id: sessionId,
    items: []
  };
  carts.push(newCart);
  await writeCarts(carts);
  return newCart.id;
}

export async function addLocalCartItem({
  cartId,
  variantId,
  qty
}: {
  cartId: string;
  variantId: string;
  qty: number;
}): Promise<void> {
  const carts = await readCarts();
  const cart = carts.find((item) => item.id === cartId);
  if (!cart) {
    throw new Error('Cart not found');
  }
  const existing = cart.items.find((item) => item.variant_id === variantId);
  if (existing) {
    existing.qty += qty;
  } else {
    cart.items.push({ id: randomUUID(), variant_id: variantId, qty });
  }
  await writeCarts(carts);
}

export async function updateLocalCartItem({
  cartId,
  itemId,
  qty
}: {
  cartId: string;
  itemId: string;
  qty: number;
}): Promise<void> {
  const carts = await readCarts();
  const cart = carts.find((item) => item.id === cartId);
  if (!cart) {
    throw new Error('Cart not found');
  }
  const entry = cart.items.find((item) => item.id === itemId);
  if (!entry) {
    throw new Error('Cart item not found');
  }
  if (qty <= 0) {
    cart.items = cart.items.filter((item) => item.id !== itemId);
  } else {
    entry.qty = qty;
  }
  await writeCarts(carts);
}

export async function removeLocalCartItem({ cartId, itemId }: { cartId: string; itemId: string }): Promise<void> {
  const carts = await readCarts();
  const cart = carts.find((item) => item.id === cartId);
  if (!cart) {
    throw new Error('Cart not found');
  }
  cart.items = cart.items.filter((item) => item.id !== itemId);
  await writeCarts(carts);
}

export async function clearLocalCart({ cartId }: { cartId: string }): Promise<void> {
  const carts = await readCarts();
  const cart = carts.find((item) => item.id === cartId);
  if (!cart) {
    return;
  }
  cart.items = [];
  await writeCarts(carts);
}

export async function getLocalCartItems(sessionId: string): Promise<CartItem[]> {
  const [carts, products] = await Promise.all([readCarts(), getLocalProducts()]);
  const cart = carts.find((item) => item.session_id === sessionId);
  if (!cart) {
    return [];
  }
  const productMap = new Map(products.map((product) => [product.id, product]));
  const variantMap = new Map<ProductVariant['id'], { variant: ProductVariant; product: Product }>();
  for (const product of products) {
    for (const variant of product.variants) {
      variantMap.set(variant.id, { variant, product });
    }
  }
  return cart.items
    .map<CartItem | null>((item) => {
      const match = variantMap.get(item.variant_id);
      if (!match) {
        return null;
      }
      return {
        id: item.id,
        cart_id: cart.id,
        variant_id: item.variant_id,
        qty: item.qty,
        variant: match.variant,
        product: {
          id: match.product.id,
          name: match.product.name,
          primary_image_url: match.product.primary_image_url,
          vendor_slug: match.product.vendor_slug
        }
      };
    })
    .filter((entry): entry is CartItem => Boolean(entry));
}

async function readOrders(): Promise<LocalOrderRecord[]> {
  return readJson<LocalOrderRecord[]>('orders.json', []);
}

async function writeOrders(orders: LocalOrderRecord[]): Promise<void> {
  await writeJson('orders.json', orders);
}

export async function createLocalOrder({
  session_id,
  total_cents,
  status
}: {
  session_id: string;
  total_cents: number;
  status: 'pending' | 'paid' | 'failed';
}): Promise<{ id: string }> {
  const orders = await readOrders();
  const id = randomUUID();
  const order: LocalOrderRecord = {
    id,
    session_id,
    total_cents,
    status,
    created_at: new Date().toISOString()
  };
  orders.push(order);
  await writeOrders(orders);
  return { id };
}

export async function updateLocalOrderStatus(orderId: string, status: 'paid' | 'failed'): Promise<void> {
  const orders = await readOrders();
  const order = orders.find((item) => item.id === orderId);
  if (!order) {
    throw new Error('Order not found');
  }
  order.status = status;
  await writeOrders(orders);
}

export async function findLocalVariantIdByProductSlug(slug: string): Promise<string | null> {
  const products = await getLocalProducts();
  const product = products.find((item) => item.slug === slug);
  if (!product) {
    return null;
  }
  const variant = product.variants[0];
  return variant?.id ?? null;
}

export async function getLocalOrderById(orderId: string): Promise<LocalOrderRecord | null> {
  const orders = await readOrders();
  return orders.find((order) => order.id === orderId) ?? null;
}
export type LocalProductFilters = {
  q?: string;
  brands?: string[];
  priceMin?: number;
  priceMax?: number;
  isActive?: boolean | null;
  sort?: 'relevance' | 'price_asc' | 'price_desc' | 'name_asc';
};

function normalize(text: string): string {
  return text.toLowerCase();
}

function productMatchesQuery(product: Product, query: string): boolean {
  const value = normalize(query);
  return [product.name, product.sku, product.brand]
    .filter(Boolean)
    .some((field) => normalize(String(field)).includes(value));
}

function getProductPrice(product: Product): number {
  return product.variants[0]?.price_cents ?? 0;
}

export function listLocalBrands(products: Product[]): string[] {
  const unique = new Set(
    products
      .map((product) => product.brand)
      .filter((brand): brand is string => typeof brand === 'string' && brand.length > 0)
  );
  return Array.from(unique).sort((a, b) => a.localeCompare(b));
}

export function filterLocalProducts(products: Product[], filters?: LocalProductFilters): Product[] {
  if (!filters) {
    return products;
  }

  let working = [...products];

  if (filters.q) {
    working = working.filter((product) => productMatchesQuery(product, filters.q!));
  }

  if (filters.brands && filters.brands.length > 0) {
    const brandSet = new Set(filters.brands.map((brand) => brand.toLowerCase()));
    working = working.filter((product) => {
      if (!product.brand) {
        return false;
      }
      return brandSet.has(product.brand.toLowerCase());
    });
  }

  if (typeof filters.isActive === 'boolean') {
    working = working.filter((product) => product.is_active === filters.isActive);
  }

  if (typeof filters.priceMin === 'number') {
    working = working.filter((product) => getProductPrice(product) >= filters.priceMin!);
  }

  if (typeof filters.priceMax === 'number') {
    working = working.filter((product) => getProductPrice(product) <= filters.priceMax!);
  }

  const sort = filters.sort || 'relevance';
  if (sort === 'price_asc') {
    working.sort((a, b) => getProductPrice(a) - getProductPrice(b));
  } else if (sort === 'price_desc') {
    working.sort((a, b) => getProductPrice(b) - getProductPrice(a));
  } else if (sort === 'name_asc') {
    working.sort((a, b) => a.name.localeCompare(b.name));
  } else if (sort === 'relevance' && filters.q) {
    working.sort((a, b) => {
      const score = (product: Product) => {
        const q = filters.q!.toLowerCase();
        if (product.name.toLowerCase().startsWith(q)) return 0;
        if (product.sku && product.sku.toLowerCase() === q) return 0;
        if (product.name.toLowerCase().includes(q)) return 1;
        return 2;
      };
      return score(a) - score(b);
    });
  }

  return working;
}

export async function getLocalProductsForCategory(slug: string): Promise<Product[]> {
  const products = await getLocalProducts();
  return products.filter((product) => product.category_slug === slug);
}

export async function searchLocalProducts(query: string): Promise<Product[]> {
  const products = await getLocalProducts();
  const filters: LocalProductFilters = { q: query };
  return filterLocalProducts(products, filters);
}

export async function findLocalVariantBySku(sku: string): Promise<{ variant: ProductVariant; product: Product } | null> {
  const products = await getLocalProducts();
  for (const product of products) {
    for (const variant of product.variants) {
      if (variant.sku && normalize(variant.sku) === normalize(sku)) {
        return { variant, product };
      }
    }
  }
  return null;
}
