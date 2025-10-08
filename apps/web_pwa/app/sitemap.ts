import type { MetadataRoute } from 'next';
import { canonical } from '@/lib/seo';
import { getLocalCategories, getLocalProducts } from '@/lib/local-store';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const [categories, products] = await Promise.all([getLocalCategories(), getLocalProducts()]);

  const urls: MetadataRoute.Sitemap = [
    {
      url: canonical('/'),
      changeFrequency: 'weekly' as const,
      priority: 1.0
    },
    ...categories.map((category) => ({
      url: canonical(`/category/${category.slug}`),
      changeFrequency: 'weekly' as const,
      priority: 0.8
    })),
    ...products
      .filter((product) => product.is_active !== false)
      .map((product) => ({
        url: canonical(`/product/${product.slug}`),
        changeFrequency: 'weekly' as const,
        priority: 0.7
      }))
  ];

  return urls;
}
