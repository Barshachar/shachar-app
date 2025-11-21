import type { CartItem, Category, Product, Vendor } from '@/lib/types';
import {
  getLocalHeroProducts,
  getLocalNewestProducts,
  getLocalCategories,
  getLocalVendors,
  getLocalProductsForCategory,
  getLocalProductBySlug,
  getLocalCartItems,
  createLocalOrder,
  updateLocalOrderStatus,
  filterLocalProducts,
  listLocalBrands,
  searchLocalProducts,
  LocalProductFilters
} from '@/lib/local-store';

export type ProductFilters = LocalProductFilters;

function applyFilters(products: Product[], filters?: ProductFilters): Product[] {
  return filterLocalProducts(products, filters);
}

function extractBrands(products: Product[]): string[] {
  return listLocalBrands(products);
}

export async function fetchHeroProducts(filters?: ProductFilters): Promise<Product[]> {
  const products = await getLocalHeroProducts();
  return applyFilters(products, filters).slice(0, 16);
}

export async function fetchCategories(): Promise<Category[]> {
  return getLocalCategories();
}

export async function fetchVendors(): Promise<Vendor[]> {
  return getLocalVendors();
}

export async function fetchCategoryWithProducts(
  slug: string,
  filters?: ProductFilters
): Promise<{
  category: Category | null;
  products: Product[];
  brands: string[];
}> {
  const [categories, products] = await Promise.all([
    getLocalCategories(),
    getLocalProductsForCategory(slug)
  ]);
  const category = categories.find((item) => item.slug === slug) ?? null;
  const brands = extractBrands(products);
  const filtered = applyFilters(products, filters);
  return { category, products: filtered, brands };
}

export async function fetchProductBySlug(slug: string): Promise<Product | null> {
  return getLocalProductBySlug(slug);
}

export async function searchProducts(filters: ProductFilters): Promise<Product[]> {
  if (filters.q) {
    const results = await searchLocalProducts(filters.q);
    return applyFilters(results, filters);
  }
  const all = await getLocalHeroProducts();
  return applyFilters(all, filters);
}

export async function fetchNewestProducts(limit = 8): Promise<Product[]> {
  return getLocalNewestProducts(limit);
}

export async function fetchCartItems(sessionId: string): Promise<CartItem[]> {
  return getLocalCartItems(sessionId);
}

export async function createOrUpdateOrder(input: {
  session_id: string;
  customer_id?: string | null;
  total_cents: number;
  status: 'pending' | 'paid' | 'failed';
}): Promise<{ id: string }> {
  return createLocalOrder({
    session_id: input.session_id,
    total_cents: input.total_cents,
    status: input.status
  });
}

export async function updateOrderStatus(orderId: string, status: 'paid' | 'failed') {
  await updateLocalOrderStatus(orderId, status);
}
