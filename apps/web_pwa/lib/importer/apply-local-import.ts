import { promises as fs } from 'node:fs';
import path from 'node:path';
import {
  upsertCatalog,
  parseCsv,
  type CsvRecord,
  type ImportSummary,
  type CsvParseError
} from './local-import';
import type { Category, Product, ProductVariant } from '../types';

async function readJsonFile<T>(filePath: string, fallback: T): Promise<T> {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    return JSON.parse(content) as T;
  } catch (error: any) {
    if (error.code === 'ENOENT') {
      return fallback;
    }
    throw error;
  }
}

async function writeJsonFile<T>(filePath: string, data: T): Promise<void> {
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
}

async function backupFile(source: string, backupDir: string): Promise<void> {
  try {
    await fs.access(source);
  } catch (error) {
    return;
  }
  await fs.mkdir(backupDir, { recursive: true });
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const fileName = path.basename(source);
  await fs.copyFile(source, path.join(backupDir, `${timestamp}-${fileName}`));
}

type ApplyOptions = {
  dataDir?: string;
  dryRun?: boolean;
};

type ApplyResult = {
  summary: ImportSummary;
  counts: { categories: number; products: number; variants: number };
  records: CsvRecord[];
  errors: CsvParseError[];
  totalRows: number;
  dryRun: boolean;
};

function resolveOptions(options?: string | ApplyOptions): { dataDir: string; dryRun: boolean } {
  const defaultDir = path.join(process.cwd(), 'data');
  if (!options) {
    return { dataDir: defaultDir, dryRun: false };
  }
  if (typeof options === 'string') {
    return { dataDir: options, dryRun: false };
  }
  return {
    dataDir: options.dataDir ? path.resolve(options.dataDir) : defaultDir,
    dryRun: options.dryRun ?? false
  };
}

export async function applyLocalCatalogImport(csvContent: string, options?: string | ApplyOptions): Promise<ApplyResult> {
  const { dataDir, dryRun } = resolveOptions(options);
  const { records, errors, totalRows } = parseCsv(csvContent);

  const categoriesPath = path.join(dataDir, 'categories.json');
  const productsPath = path.join(dataDir, 'products.json');
  const variantsPath = path.join(dataDir, 'variants.json');
  const backupDir = path.join(dataDir, 'backup');

  const [categories, products, variants] = await Promise.all([
    readJsonFile<Category[]>(categoriesPath, []),
    readJsonFile<Product[]>(productsPath, []),
    readJsonFile<ProductVariant[]>(variantsPath, [])
  ]);

  if (!records.length) {
    return {
      summary: {
        categories: { added: 0, updated: 0, skipped: 0 },
        products: { added: 0, updated: 0, skipped: 0 },
        variants: { added: 0, updated: 0, skipped: 0 }
      },
      counts: {
        categories: categories.length,
        products: products.length,
        variants: variants.length
      },
      records,
      errors,
      totalRows,
      dryRun
    };
  }

  const result = upsertCatalog(records, categories, products, variants);
  const plainProducts = result.products.map(({ variants: _variants, ...rest }) => rest);

  if (!dryRun) {
    await Promise.all([
      backupFile(categoriesPath, backupDir),
      backupFile(productsPath, backupDir),
      backupFile(variantsPath, backupDir)
    ]);

    await Promise.all([
      writeJsonFile(categoriesPath, result.categories.sort((a, b) => a.slug.localeCompare(b.slug))),
      writeJsonFile(productsPath, plainProducts.sort((a, b) => a.slug.localeCompare(b.slug))),
      writeJsonFile(variantsPath, result.variants.sort((a, b) => a.id.localeCompare(b.id)))
    ]);
  }

  return {
    summary: result.summary,
    counts: {
      categories: result.categories.length,
      products: plainProducts.length,
      variants: result.variants.length
    },
    records,
    errors,
    totalRows,
    dryRun
  };
}
