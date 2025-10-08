#!/usr/bin/env node
import { promises as fs } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { performance } from 'node:perf_hooks';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i += 1) {
    const key = argv[i];
    if (!key.startsWith('--')) {
      continue;
    }
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      args[key.slice(2)] = true;
    } else {
      args[key.slice(2)] = next;
      i += 1;
    }
  }
  return args;
}

function parseCsvLine(line) {
  const cells = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      cells.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  cells.push(current.trim());
  return cells;
}

function parseCsv(text) {
  const lines = text.split(/\r?\n/).filter((line) => line.trim().length > 0);
  if (lines.length === 0) return [];
  const headers = parseCsvLine(lines[0]);
  return lines.slice(1).map((line) => {
    const cells = parseCsvLine(line);
    const record = {};
    headers.forEach((header, index) => {
      record[header] = cells[index] ?? '';
    });
    return record;
  });
}

function formatN(number) {
  return new Intl.NumberFormat('he-IL').format(number);
}

async function main() {
  const args = parseArgs(process.argv);
  const inputPath = resolve(
    args.input || 'apps/web_pwa/data/sample-import.csv'
  );
  const logDir = resolve(args.logdir || 'logs/imports');

  const begin = performance.now();
  const content = await fs.readFile(inputPath, 'utf8');
  const rows = parseCsv(content);

  if (rows.length === 0) {
    console.error(`[import] No rows parsed from ${inputPath}`);
    process.exitCode = 1;
    return;
  }

  const timestamp = new Date().toISOString();
  const byBrand = new Map();
  const byCategory = new Map();
  const seenSku = new Set();
  const duplicates = new Set();
  let minPrice = Number.POSITIVE_INFINITY;
  let maxPrice = 0;
  let priceSum = 0;

  rows.forEach((row) => {
    const brand = row.brand || 'unknown';
    const category = row.category_slug || 'uncategorized';
    const sku = row.sku || 'unknown';
    const priceCents = Number.parseInt(row.price_cents ?? '0', 10) || 0;

    byBrand.set(brand, (byBrand.get(brand) ?? 0) + 1);
    byCategory.set(category, (byCategory.get(category) ?? 0) + 1);

    if (seenSku.has(sku)) {
      duplicates.add(sku);
    } else {
      seenSku.add(sku);
    }

    minPrice = Math.min(minPrice, priceCents);
    maxPrice = Math.max(maxPrice, priceCents);
    priceSum += priceCents;
  });

  const durationMs = performance.now() - begin;
  const avgPrice = rows.length ? priceSum / rows.length : 0;

  await fs.mkdir(logDir, { recursive: true });
  const logPath = resolve(
    logDir,
    `catalog-delta-${timestamp.replace(/[:.]/g, '-')}.log`
  );

  const summary = {
    timestamp,
    input: inputPath,
    rows: rows.length,
    uniques: {
      brands: byBrand.size,
      categories: byCategory.size,
    },
    prices: {
      min: minPrice / 100,
      max: maxPrice / 100,
      average: Math.round((avgPrice / 100) * 100) / 100,
    },
    duplicates: Array.from(duplicates),
    durationMs: Math.round(durationMs),
  };

  const logLines = [
    `# Catalog Delta Import Report`,
    `timestamp: ${timestamp}`,
    `source: ${inputPath}`,
    `rows: ${rows.length}`,
    `unique brands: ${byBrand.size}`,
    `unique categories: ${byCategory.size}`,
    `price range: ₪${(minPrice / 100).toFixed(2)} - ₪${(maxPrice / 100).toFixed(2)}`,
    `avg price: ₪${(avgPrice / 100).toFixed(2)}`,
    `duplicates: ${duplicates.size ? Array.from(duplicates).join(', ') : 'none'}`,
    `duration_ms: ${Math.round(durationMs)}`,
    '',
    'Top brands:',
  ];

  Array.from(byBrand.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .forEach(([brand, count]) => {
      logLines.push(`  - ${brand}: ${count}`);
    });

  logLines.push('', 'Top categories:');
  Array.from(byCategory.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .forEach(([category, count]) => {
      logLines.push(`  - ${category}: ${count}`);
    });

  await fs.writeFile(logPath, logLines.join('\n'), 'utf8');

  console.log(`✔ Processed ${formatN(rows.length)} rows in ${Math.round(durationMs)} ms`);
  console.log(`   log file: ${logPath}`);
  console.table(
    Array.from(byBrand.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([brand, count]) => ({ brand, count }))
  );

  console.log('Summary:', JSON.stringify(summary, null, 2));
}

main().catch((error) => {
  console.error('[import] Failed:', error);
  process.exitCode = 1;
});
