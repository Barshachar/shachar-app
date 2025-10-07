#!/usr/bin/env ts-node
import fs from 'node:fs/promises';
import path from 'node:path';
import { applyLocalCatalogImport } from '../lib/importer/apply-local-import';

type CliOptions = {
  csvPath: string;
  dataDir?: string;
  dryRun: boolean;
};

function printUsage() {
  console.error(
    'Usage: npm run import:csv -- [--dry-run] [--data-dir <dir>] <path-to-csv>'
  );
}

function parseArgs(): CliOptions | null {
  const args = process.argv.slice(2);
  let dryRun = false;
  let dataDir: string | undefined;
  const positional: string[] = [];

  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg === '--dry-run' || arg === '--preview' || arg === '-n') {
      dryRun = true;
      continue;
    }
    if (arg.startsWith('--data-dir=')) {
      dataDir = path.resolve(arg.split('=')[1] ?? '');
      continue;
    }
    if (arg === '--data-dir') {
      const next = args[i + 1];
      if (!next) {
        console.error('Missing value for --data-dir option.');
        return null;
      }
      dataDir = path.resolve(next);
      i += 1;
      continue;
    }
    positional.push(arg);
  }

  const csvPath = positional[0];
  if (!csvPath) {
    return null;
  }

  return { csvPath: path.resolve(csvPath), dataDir, dryRun };
}

async function main() {
  const options = parseArgs();
  if (!options) {
    printUsage();
    process.exit(1);
  }

  const { csvPath, dataDir, dryRun } = options;
  const content = await fs.readFile(csvPath, 'utf8');
  const result = await applyLocalCatalogImport(content, {
    dataDir,
    dryRun
  });

  const processed = result.records.length;
  const failed = result.errors.length;

  console.log(`[Import] total rows: ${result.totalRows}, processed: ${processed}, failed: ${failed}`);
  console.log('Categories -> added:', result.summary.categories.added, 'updated:', result.summary.categories.updated, 'skipped:', result.summary.categories.skipped);
  console.log('Products   -> added:', result.summary.products.added, 'updated:', result.summary.products.updated, 'skipped:', result.summary.products.skipped);
  console.log('Variants   -> added:', result.summary.variants.added, 'updated:', result.summary.variants.updated, 'skipped:', result.summary.variants.skipped);
  console.log('Catalog counts:', result.counts);

  if (dryRun) {
    console.log('Dry run enabled — no files were modified.');
  }

  if (failed) {
    console.log('\nFailed rows:');
    for (const error of result.errors) {
      const preview = error.rowPreview ? ` (${error.rowPreview})` : '';
      console.log(`  • line ${error.line}${preview}: ${error.message}`);
    }
  }

  if (!processed && !failed) {
    console.log('No valid rows found in CSV.');
  }
}

main().catch((error) => {
  console.error('Import failed:', error instanceof Error ? error.message : error);
  process.exit(1);
});
