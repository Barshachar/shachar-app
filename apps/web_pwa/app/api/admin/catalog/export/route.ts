import { NextRequest, NextResponse } from 'next/server';
import { promises as fs } from 'node:fs';
import { guardAdminApiRequest } from '@/lib/admin/guard';
import { assertLocalMode } from '@/lib/admin/local-mode';
import { PRODUCTS_PATH, VARIANTS_PATH, CATEGORIES_PATH } from '@/lib/admin/catalog-files';

type ExportKey = 'products' | 'variants' | 'categories';

const EXPORT_MAP: Record<ExportKey, { path: string; fileName: string }> = {
  products: { path: PRODUCTS_PATH, fileName: 'products.json' },
  variants: { path: VARIANTS_PATH, fileName: 'variants.json' },
  categories: { path: CATEGORIES_PATH, fileName: 'categories.json' }
};

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

  const url = new URL(request.url);
  const fileKey = url.searchParams.get('file');

  if (!fileKey || !['products', 'variants', 'categories'].includes(fileKey)) {
    return NextResponse.json({ error: 'Unknown export target' }, { status: 400 });
  }

  const descriptor = EXPORT_MAP[fileKey as ExportKey];

  try {
    const data = await fs.readFile(descriptor.path, 'utf8');
    return new NextResponse(data, {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Content-Disposition': `attachment; filename="${descriptor.fileName}"`,
        'Cache-Control': 'no-store'
      }
    });
  } catch (error: any) {
    if (error?.code === 'ENOENT') {
      return NextResponse.json({ error: 'File not found' }, { status: 404 });
    }
    throw error;
  }
}
