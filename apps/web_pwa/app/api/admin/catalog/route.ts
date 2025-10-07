import { NextRequest, NextResponse } from 'next/server';
import type { Product, ProductVariant } from '@/lib/types';
import { guardAdminApiRequest } from '@/lib/admin/guard';
import { isAdminReadOnly } from '@/lib/admin/access';
import { ensureCategory, loadCatalog, saveCatalog, vendorSlug, backupCatalogFiles } from '@/lib/admin/catalog-files';
import { assertLocalMode } from '@/lib/admin/local-mode';

type CatalogResponseProduct = Product & {
  default_variant?: ProductVariant | null;
};

type CatalogProductPayload = {
  id?: string;
  name: string;
  slug: string;
  sku?: string;
  brand?: string;
  category_slug: string;
  primary_image_url?: string;
  description_html?: string;
  is_active?: boolean;
  price_cents: number;
  created_at?: string;
};

function mergeProducts(products: Product[], variants: ProductVariant[]): CatalogResponseProduct[] {
  const variantMap = new Map(variants.map((variant) => [variant.product_id, variant]));
  return products.map((product) => ({
    ...product,
    default_variant: variantMap.get(product.id) ?? null
  }));
}

function guardReadOnlyResponse(): NextResponse | null {
  if (!isAdminReadOnly()) {
    return null;
  }
  return NextResponse.json({ error: 'Admin catalog is read-only' }, { status: 403 });
}

export async function GET(request: NextRequest) {
  const adminGuard = guardAdminApiRequest(request);
  if (adminGuard) {
    return adminGuard;
  }
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const { products, variants, categories } = await loadCatalog();
  const merged = mergeProducts(products, variants);
  const url = new URL(request.url);
  const q = url.searchParams.get('q')?.toLowerCase() ?? '';
  const brand = url.searchParams.get('brand')?.toLowerCase();
  const categorySlug = url.searchParams.get('category');

  const filtered = merged.filter((product) => {
    if (q && ![product.name, product.sku, product.brand].filter(Boolean).some((value) => value!.toLowerCase().includes(q))) {
      return false;
    }
    if (brand && product.brand?.toLowerCase() !== brand) {
      return false;
    }
    if (categorySlug && product.category_slug !== categorySlug) {
      return false;
    }
    return true;
  });

  return NextResponse.json({
    products: filtered,
    categories,
    brands: Array.from(new Set(products.map((product) => product.brand).filter(Boolean))).sort(),
    readOnly: isAdminReadOnly()
  });
}

export async function POST(request: NextRequest) {
  const adminGuard = guardAdminApiRequest(request);
  if (adminGuard) {
    return adminGuard;
  }
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const readOnlyResponse = guardReadOnlyResponse();
  if (readOnlyResponse) {
    return readOnlyResponse;
  }

  const payload = (await request.json()) as { action: string; product?: CatalogProductPayload };
  if (!payload || !payload.action) {
    return NextResponse.json({ error: 'Unsupported action' }, { status: 400 });
  }

  if (payload.action === 'backup') {
    const files = await backupCatalogFiles();
    return NextResponse.json({ ok: true, files });
  }

  if (payload.action !== 'upsert' || !payload.product) {
    return NextResponse.json({ error: 'Unsupported action' }, { status: 400 });
  }

  const { products, variants, categories } = await loadCatalog();
  const input = payload.product;
  const slug = input.slug.trim().toLowerCase();
  if (!slug) {
    return NextResponse.json({ error: 'slug is required' }, { status: 400 });
  }
  const productId = input.id || products.find((item) => item.slug === slug)?.id || `p_${slug}`;
  const variantId = `v_${slug}_default`;
  const brand = input.brand?.trim() || '';
  const vendor = vendorSlug(brand);
  const price = Number(input.price_cents);
  if (Number.isNaN(price) || price <= 0) {
    return NextResponse.json({ error: 'price_cents must be a positive number' }, { status: 400 });
  }

  const updatedProducts: Product[] = [...products];
  const existingIndex = updatedProducts.findIndex((item) => item.id === productId || item.slug === slug);
  const existingProduct = existingIndex === -1 ? null : updatedProducts[existingIndex];
  const createdAt = existingProduct?.created_at ?? input.created_at ?? new Date().toISOString();
  const baseProduct: Product = {
    id: productId,
    name: input.name || slug,
    slug,
    sku: input.sku || slug.toUpperCase(),
    brand: brand || 'א.שחר',
    vendor_slug: vendor,
    category_slug: input.category_slug.trim() || 'general',
    primary_image_url: input.primary_image_url || '/placeholders/p0.png',
    description_html: input.description_html || '<p>ללא תיאור</p>',
    is_active: input.is_active !== false,
    created_at: createdAt,
    variants: []
  };

  if (existingIndex === -1) {
    updatedProducts.push(baseProduct);
  } else {
    updatedProducts[existingIndex] = {
      ...baseProduct,
      id: updatedProducts[existingIndex].id,
      created_at: createdAt
    };
  }

  const updatedVariants: ProductVariant[] = [...variants];
  const variantIndex = updatedVariants.findIndex((item) => item.id === variantId);
  const baseVariant: ProductVariant = {
    id: variantId,
    product_id: productId,
    name: 'ברירת מחדל',
    sku: `${baseProduct.sku}-DEF`,
    price_cents: price,
    currency: 'ILS',
    barcode: null,
    variant_prices: [
      {
        price_group: 'installer',
        price_cents: Math.round(price * 0.9)
      }
    ]
  };

  if (variantIndex === -1) {
    updatedVariants.push(baseVariant);
  } else {
    updatedVariants[variantIndex] = { ...baseVariant, id: updatedVariants[variantIndex].id };
  }

  const updatedCategories = ensureCategory(categories, baseProduct.category_slug);

  await saveCatalog({ products: updatedProducts, variants: updatedVariants, categories: updatedCategories });

  return NextResponse.json({ ok: true });
}

export async function DELETE(request: NextRequest) {
  const adminGuard = guardAdminApiRequest(request);
  if (adminGuard) {
    return adminGuard;
  }
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const readOnlyResponse = guardReadOnlyResponse();
  if (readOnlyResponse) {
    return readOnlyResponse;
  }

  const { searchParams } = new URL(request.url);
  const slug = searchParams.get('slug');
  if (!slug) {
    return NextResponse.json({ error: 'slug parameter required' }, { status: 400 });
  }

  const { products, variants, categories } = await loadCatalog();
  const filteredProducts = products.filter((product) => product.slug !== slug);
  const removedProduct = products.length !== filteredProducts.length;
  const filteredVariants = variants.filter((variant) => !variant.id.startsWith(`v_${slug}_`));

  if (!removedProduct) {
    return NextResponse.json({ error: 'Product not found' }, { status: 404 });
  }

  await saveCatalog({ products: filteredProducts, variants: filteredVariants, categories });

  return NextResponse.json({ ok: true });
}
