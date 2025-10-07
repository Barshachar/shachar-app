import type { Product } from '@/lib/types';

export function getBaseUrl(): string {
  const envUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (envUrl && envUrl.trim().length > 0) {
    return envUrl.replace(/\/$/, '');
  }
  return 'http://localhost:3003';
}

export function canonical(path = ''): string {
  const baseUrl = getBaseUrl();
  if (!path) {
    return baseUrl;
  }
  const normalized = path.startsWith('/') ? path : `/${path}`;
  return `${baseUrl}${normalized}`;
}

export function orgJsonLd() {
  const baseUrl = getBaseUrl();
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'א.שחר • אינסטלציה סיטונאית',
    url: baseUrl,
    sameAs: [] as string[]
  };
}

export function breadcrumbJsonLd(items: { name: string; url: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: item.url
    }))
  };
}

export function productJsonLd(product: Product, {
  priceCents,
  image,
  brandLabel
}: {
  priceCents: number;
  image: string;
  brandLabel: string | null;
}) {
  const baseUrl = getBaseUrl();
  const description = (product.description_html || '').replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
  return {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    sku: product.sku || undefined,
    brand: brandLabel ? { '@type': 'Brand', name: brandLabel } : undefined,
    image,
    description,
    offers: {
      '@type': 'Offer',
      priceCurrency: 'ILS',
      price: (priceCents / 100).toFixed(2),
      availability: product.is_active ? 'http://schema.org/InStock' : 'http://schema.org/OutOfStock',
      url: canonical(`/product/${product.slug}`)
    },
    url: canonical(`/product/${product.slug}`)
  };
}
