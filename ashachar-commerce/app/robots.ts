import type { MetadataRoute } from 'next';
import { canonical } from '@/lib/seo';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      disallow: ['/admin', '/api/admin', '/api/admin/*']
    },
    sitemap: canonical('/sitemap.xml')
  };
}
