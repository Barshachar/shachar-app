import { createServerClient, createServiceRoleClient } from '@/lib/supabase-server';
import type { CartItem, Category, Product, Vendor } from '@/lib/types';
import {
  shouldUseLocalData,
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

function isLocalMode() {
  return shouldUseLocalData();
}

function applyFilters(products: Product[], filters?: ProductFilters): Product[] {
  if (!filters) {
    return products;
  }
  return filterLocalProducts(products, filters);
}

function extractBrands(products: Product[]): string[] {
  return listLocalBrands(products);
}

export async function fetchHeroProducts(filters?: ProductFilters): Promise<Product[]> {
  if (isLocalMode()) {
    const products = await getLocalHeroProducts();
    return applyFilters(products, filters).slice(0, 16);
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('products')
      .select(
        'id,name,slug,sku,brand,vendor_slug,category_slug,primary_image_url,description_html,is_active,created_at,product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents))'
      )
      .eq('is_active', true)
      .order('created_at', { ascending: false })
      .limit(50);

    if (error || !data) {
      throw error;
    }

    const mapped = (data as any[]).map((row) => ({
      id: row.id,
      name: row.name,
      slug: row.slug,
      sku: row.sku,
      brand: row.brand,
      vendor_slug: row.vendor_slug,
      category_slug: row.category_slug,
      primary_image_url: row.primary_image_url,
      description_html: row.description_html,
      is_active: row.is_active,
      created_at: row.created_at ?? null,
      variants: (row.product_variants || []).map((variant: any) => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price_cents: variant.price_cents,
        currency: variant.currency,
        barcode: variant.barcode,
        variant_prices: variant.variant_prices || []
      }))
    })) as Product[];

    return applyFilters(mapped, filters);
  } catch (err) {
    console.warn('Falling back to local hero products', err);
    return applyFilters(await getLocalHeroProducts(), filters).slice(0, 16);
  }
}

export async function fetchCategories(): Promise<Category[]> {
  if (isLocalMode()) {
    return getLocalCategories();
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('categories')
      .select('id,name,slug,image_url,parent_id')
      .is('parent_id', null)
      .order('name');
    if (error || !data) {
      throw error;
    }
    return data as Category[];
  } catch (err) {
    console.warn('Falling back to local categories', err);
    return getLocalCategories();
  }
}

export async function fetchVendors(): Promise<Vendor[]> {
  if (isLocalMode()) {
    return getLocalVendors();
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('vendors')
      .select('id,name,slug,logo_url')
      .order('name');
    if (error || !data) {
      throw error;
    }
    return data as Vendor[];
  } catch (err) {
    console.warn('Falling back to local vendors', err);
    return getLocalVendors();
  }
}

export async function fetchCategoryWithProducts(
  slug: string,
  filters?: ProductFilters
): Promise<{
  category: Category | null;
  products: Product[];
  brands: string[];
}> {
  if (isLocalMode()) {
    const [categories, products] = await Promise.all([
      getLocalCategories(),
      getLocalProductsForCategory(slug)
    ]);
    const category = categories.find((item) => item.slug === slug) ?? null;
    const brands = extractBrands(products);
    const filtered = applyFilters(products, filters);
    return { category, products: filtered, brands };
  }

  try {
    const supabase = createServerClient();
    const [{ data: category }, { data: products }] = await Promise.all([
      supabase.from('categories').select('id,name,slug,image_url,parent_id').eq('slug', slug).maybeSingle(),
      supabase
        .from('products')
        .select(
          'id,name,slug,sku,brand,vendor_slug,category_slug,primary_image_url,description_html,is_active,created_at,product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents))'
        )
        .eq('category_slug', slug)
        .order('name')
    ]);

    const mapped = ((products as any[]) || []).map((row) => ({
      id: row.id,
      name: row.name,
      slug: row.slug,
      sku: row.sku,
      brand: row.brand,
      vendor_slug: row.vendor_slug,
      category_slug: row.category_slug,
      primary_image_url: row.primary_image_url,
      description_html: row.description_html,
      is_active: row.is_active,
      created_at: row.created_at ?? null,
      variants: (row.product_variants || []).map((variant: any) => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price_cents: variant.price_cents,
        currency: variant.currency,
        barcode: variant.barcode,
        variant_prices: variant.variant_prices || []
      }))
    })) as Product[];

    const brands = extractBrands(mapped);
    return {
      category: category ? (category as Category) : null,
      products: applyFilters(mapped, filters),
      brands
    };
  } catch (err) {
    console.warn('Falling back to local category products', err);
    const [categories, products] = await Promise.all([
      getLocalCategories(),
      getLocalProductsForCategory(slug)
    ]);
    const category = categories.find((item) => item.slug === slug) ?? null;
    return { category, products: applyFilters(products, filters), brands: extractBrands(products) };
  }
}

export async function fetchProductBySlug(slug: string): Promise<Product | null> {
  if (isLocalMode()) {
    return getLocalProductBySlug(slug);
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('products')
      .select(
        'id,name,slug,sku,brand,vendor_slug,category_slug,primary_image_url,description_html,is_active,created_at,product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents))'
      )
      .eq('slug', slug)
      .maybeSingle();
    if (error) {
      throw error;
    }
    if (!data) {
      return null;
    }
    const record = data as any;
    return {
      id: record.id,
      name: record.name,
      slug: record.slug,
      sku: record.sku,
      brand: record.brand,
      vendor_slug: record.vendor_slug,
      category_slug: record.category_slug,
      primary_image_url: record.primary_image_url,
      description_html: record.description_html,
      is_active: record.is_active,
      created_at: record.created_at ?? null,
      variants: (record.product_variants || []).map((variant: any) => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price_cents: variant.price_cents,
        currency: variant.currency,
        barcode: variant.barcode,
        variant_prices: variant.variant_prices || []
      }))
    } as Product;
  } catch (err) {
    console.warn('Falling back to local product', err);
    return getLocalProductBySlug(slug);
  }
}

export async function searchProducts(filters: ProductFilters): Promise<Product[]> {
  if (isLocalMode()) {
    if (filters.q) {
      const results = await searchLocalProducts(filters.q);
      return applyFilters(results, filters);
    }
    const all = await getLocalHeroProducts();
    return applyFilters(all, filters);
  }

  try {
    const supabase = createServerClient();
    const query = supabase
      .from('products')
      .select(
        'id,name,slug,sku,brand,vendor_slug,category_slug,primary_image_url,description_html,is_active,created_at,product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents))'
      )
      .limit(100);

    if (filters.q) {
      query.ilike('name', `%${filters.q}%`);
    }

    const { data, error } = await query;
    if (error || !data) {
      throw error;
    }
    const mapped = (data as any[]).map((row) => ({
      id: row.id,
      name: row.name,
      slug: row.slug,
      sku: row.sku,
      brand: row.brand,
      vendor_slug: row.vendor_slug,
      category_slug: row.category_slug,
      primary_image_url: row.primary_image_url,
      description_html: row.description_html,
      is_active: row.is_active,
      created_at: row.created_at ?? null,
      variants: (row.product_variants || []).map((variant: any) => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price_cents: variant.price_cents,
        currency: variant.currency,
        barcode: variant.barcode,
        variant_prices: variant.variant_prices || []
      }))
    })) as Product[];
    return applyFilters(mapped, filters);
  } catch (err) {
    console.warn('Falling back to local search', err);
    const results = await searchLocalProducts(filters.q ?? '');
    return applyFilters(results, filters);
  }
}

export async function fetchNewestProducts(limit = 8): Promise<Product[]> {
  if (isLocalMode()) {
    return getLocalNewestProducts(limit);
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('products')
      .select(
        'id,name,slug,sku,brand,vendor_slug,category_slug,primary_image_url,description_html,is_active,created_at,product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents))'
      )
      .eq('is_active', true)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error || !data) {
      throw error;
    }

    return (data as any[]).map((row) => ({
      id: row.id,
      name: row.name,
      slug: row.slug,
      sku: row.sku,
      brand: row.brand,
      vendor_slug: row.vendor_slug,
      category_slug: row.category_slug,
      primary_image_url: row.primary_image_url,
      description_html: row.description_html,
      is_active: row.is_active,
      created_at: row.created_at ?? null,
      variants: (row.product_variants || []).map((variant: any) => ({
        id: variant.id,
        name: variant.name,
        sku: variant.sku,
        price_cents: variant.price_cents,
        currency: variant.currency,
        barcode: variant.barcode,
        variant_prices: variant.variant_prices || []
      }))
    })) as Product[];
  } catch (err) {
    console.warn('Falling back to local newest products', err);
    return getLocalNewestProducts(limit);
  }
}

export async function fetchCartItems(sessionId: string): Promise<CartItem[]> {
  if (isLocalMode()) {
    return getLocalCartItems(sessionId);
  }

  try {
    const supabase = createServerClient();
    const { data, error } = await supabase
      .from('cart_items_view')
      .select(
        'id,cart_id,variant_id,qty,variant:product_variants(id,name,sku,price_cents,currency,barcode,variant_prices(price_group,price_cents)),product:products(id,name,primary_image_url,vendor_slug)'
      )
      .eq('cart_id', sessionId);
    if (error || !data) {
      throw error;
    }
    return data as unknown as CartItem[];
  } catch (err) {
    console.warn('Falling back to local cart items', err);
    return getLocalCartItems(sessionId);
  }
}

export async function createOrUpdateOrder(
  input: {
    session_id: string;
    customer_id?: string | null;
    total_cents: number;
    status: 'pending' | 'paid' | 'failed';
  }
): Promise<{ id: string }> {
  if (isLocalMode()) {
    return createLocalOrder({
      session_id: input.session_id,
      total_cents: input.total_cents,
      status: input.status
    });
  }

  const supabase = createServiceRoleClient() as any;
  const { data, error } = await supabase
    .from('orders')
    .insert({
      session_id: input.session_id,
      customer_id: input.customer_id || null,
      total_cents: input.total_cents,
      status: input.status
    })
    .select('id')
    .single();
  if (error) {
    throw error;
  }
  return { id: data.id };
}

export async function updateOrderStatus(orderId: string, status: 'paid' | 'failed') {
  if (isLocalMode()) {
    return updateLocalOrderStatus(orderId, status);
  }

  const supabase = createServiceRoleClient() as any;
  const { error } = await supabase.from('orders').update({ status }).eq('id', orderId);
  if (error) {
    throw error;
  }
}
