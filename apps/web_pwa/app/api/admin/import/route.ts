import { NextResponse } from 'next/server';
import { applyLocalCatalogImport } from '@/lib/importer/apply-local-import';

export const runtime = 'nodejs';

export async function POST(request: Request) {
  if (process.env.APP_DATA_MODE !== 'local') {
    return NextResponse.json({ error: 'Local data mode required' }, { status: 403 });
  }

  const formData = await request.formData();
  const file = formData.get('file');
  if (!(file instanceof File)) {
    return NextResponse.json({ error: 'Missing CSV file' }, { status: 400 });
  }

  const content = await file.text();
  if (!content.trim()) {
    return NextResponse.json({ error: 'CSV file is empty' }, { status: 400 });
  }

  try {
    const result = await applyLocalCatalogImport(content);
    return NextResponse.json({
      ok: result.errors.length === 0,
      processed: result.records.length,
      failed: result.errors.length,
      totalRows: result.totalRows,
      summary: result.summary,
      counts: result.counts,
      errors: result.errors
    });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Import failed' },
      { status: 500 }
    );
  }
}
