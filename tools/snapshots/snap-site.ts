import fs from 'fs';
import os from 'os';
import path from 'path';
import puppeteer, { Page } from 'puppeteer';
import type { Browser } from 'puppeteer';
import { XMLParser } from 'fast-xml-parser';

type Method = 'json' | 'sitemap';

type CliOptions = {
  base: string;
  pin?: string;
  out: string;
  method: Method;
  max: number;
  concurrency: number;
};

type CrawlTarget = {
  url: string;
  isAdmin: boolean;
  fileBase: string;
};

type PreparedTarget = CrawlTarget & {
  outputPath: string;
};

type FailureRecord = {
  url: string;
  error: string;
};

const MAX_PRODUCT_COUNT = 100;
const MAX_ATTEMPTS = 3;

function parseArgs(argv: string[]): CliOptions {
  const raw: Record<string, string | undefined> = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) {
      continue;
    }
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (next === undefined || next.startsWith('--')) {
      const maybeValue = arg.split('=')[1];
      if (maybeValue) {
        raw[key] = maybeValue;
      }
      continue;
    }
    raw[key] = next;
    i += 1;
  }

  const base = raw.base ?? 'http://localhost:3003';
  let pin: string | undefined = raw.pin ?? '21772177';
  if (pin && pin.trim().length === 0) {
    pin = undefined;
  }
  const method = (raw.method as Method | undefined) ?? 'json';
  if (method !== 'json' && method !== 'sitemap') {
    throw new Error(`Unsupported --method value: ${raw.method}`);
  }

  const max = raw.max ? Number.parseInt(raw.max, 10) : 150;
  if (Number.isNaN(max) || max <= 0) {
    throw new Error('Invalid --max value');
  }

  const concurrency = raw.concurrency ? Number.parseInt(raw.concurrency, 10) : 4;
  if (Number.isNaN(concurrency) || concurrency <= 0) {
    throw new Error('Invalid --concurrency value');
  }

  const outArg = raw.out;
  const out = resolveOutputDir(outArg);

  const normalizedBase = new URL(base).toString().replace(/\/$/, '');

  return {
    base: normalizedBase,
    pin,
    out,
    method,
    max,
    concurrency
  };
}

function resolveOutputDir(outArg?: string): string {
  const timestamp = formatTimestamp(new Date());
  const home = os.homedir();
  const defaultDir = path.join(home, 'Desktop', 'ashachar-snaps', timestamp);
  if (!outArg) {
    return defaultDir;
  }
  if (outArg === '~') {
    return home;
  }
  if (outArg.startsWith('~/')) {
    return path.resolve(path.join(home, outArg.slice(2)));
  }
  if (outArg.startsWith('~')) {
    return path.resolve(path.join(home, outArg.slice(1)));
  }
  return path.resolve(outArg);
}

function formatTimestamp(date: Date): string {
  const pad = (num: number) => num.toString().padStart(2, '0');
  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1);
  const day = pad(date.getDate());
  const hours = pad(date.getHours());
  const minutes = pad(date.getMinutes());
  const seconds = pad(date.getSeconds());
  return `${year}${month}${day}-${hours}${minutes}${seconds}`;
}

async function discoverTargets(baseUrl: URL, options: CliOptions): Promise<CrawlTarget[]> {
  if (options.method === 'sitemap') {
    console.log('OK: discover sitemap');
    return discoverFromSitemap(baseUrl);
  }
  console.log('OK: discover json');
  return discoverFromJson(baseUrl, Boolean(options.pin));
}

async function discoverFromJson(baseUrl: URL, includeAdmin: boolean): Promise<CrawlTarget[]> {
  const seen = new Map<string, CrawlTarget>();
  const register = (input: string, isAdmin = false) => {
    const absolute = new URL(input, baseUrl).toString();
    if (!absolute.startsWith(baseUrl.origin)) {
      return;
    }
    const fileBase = buildFileBase(new URL(absolute), isAdmin);
    const existing = seen.get(absolute);
    if (existing) {
      if (isAdmin && !existing.isAdmin) {
        seen.set(absolute, { ...existing, isAdmin: true, fileBase });
      }
      return;
    }
    seen.set(absolute, { url: absolute, isAdmin, fileBase });
  };

  const staticPaths = [
    '/',
    '/search?q=faucet',
    '/cart',
    '/checkout',
    '/terms',
    '/privacy',
    '/shipping',
    '/accessibility'
  ];
  staticPaths.forEach((p) => register(p));

  const categoriesPath = path.join(process.cwd(), 'data', 'categories.json');
  const productsPath = path.join(process.cwd(), 'data', 'products.json');

  const categoriesRaw = await fs.promises.readFile(categoriesPath, 'utf8');
  const productsRaw = await fs.promises.readFile(productsPath, 'utf8');

  const categories: Array<{ slug?: string }> = JSON.parse(categoriesRaw);
  categories
    .map((category) => category.slug)
    .filter((slug): slug is string => Boolean(slug))
    .forEach((slug) => register(`/category/${slug}`));

  type ProductShape = {
    slug?: string;
    created_at?: string;
  };

  type ProductWithIndex = {
    slug?: string;
    created_at?: string;
    index: number;
  };

  type ProductWithSlug = {
    slug: string;
    created_at?: string;
    index: number;
  };

  const hasSlug = (product: ProductWithIndex): product is ProductWithSlug =>
    typeof product.slug === 'string' && product.slug.length > 0;

  const products: ProductShape[] = JSON.parse(productsRaw);
  const withIndex = products
    .map((product, index) => ({
      slug: product.slug,
      created_at: product.created_at,
      index
    }))
    .filter(hasSlug);

  withIndex
    .sort((a, b) => {
      const dateA = a.created_at ? Date.parse(a.created_at) : Number.NEGATIVE_INFINITY;
      const dateB = b.created_at ? Date.parse(b.created_at) : Number.NEGATIVE_INFINITY;
      if (Number.isNaN(dateA) && Number.isNaN(dateB)) {
        return a.index - b.index;
      }
      if (Number.isNaN(dateA)) {
        return 1;
      }
      if (Number.isNaN(dateB)) {
        return -1;
      }
      if (dateA === dateB) {
        return a.index - b.index;
      }
      return dateB - dateA;
    })
    .slice(0, MAX_PRODUCT_COUNT)
    .forEach((product) => register(`/product/${product.slug}`));

  if (includeAdmin) {
    register('/admin/catalog', true);
    register('/admin/import', true);
  }

  return Array.from(seen.values());
}

async function discoverFromSitemap(baseUrl: URL): Promise<CrawlTarget[]> {
  const sitemapUrl = new URL('/sitemap.xml', baseUrl).toString();
  const response = await fetch(sitemapUrl);
  if (!response.ok) {
    throw new Error(`Failed to retrieve sitemap: ${response.status} ${response.statusText}`);
  }
  const xml = await response.text();
  const parser = new XMLParser();
  const parsed = parser.parse(xml) as {
    urlset?: {
      url?: Array<{ loc?: string }> | { loc?: string };
    };
  };

  const entries = parsed.urlset?.url;
  const urls: Array<{ loc?: string }> = Array.isArray(entries) ? entries : entries ? [entries] : [];
  const seen = new Map<string, CrawlTarget>();

  urls.forEach((entry) => {
    if (!entry.loc) {
      return;
    }
    try {
      const absolute = new URL(entry.loc);
      if (absolute.origin !== baseUrl.origin) {
        return;
      }
      const normalized = absolute.toString();
      if (seen.has(normalized)) {
        return;
      }
      const isAdmin = absolute.pathname.startsWith('/admin');
      const fileBase = buildFileBase(absolute, isAdmin);
      seen.set(normalized, { url: normalized, isAdmin, fileBase });
    } catch (error) {
      console.error('Sitemap entry error');
      console.error(error);
    }
  });

  return Array.from(seen.values());
}

function buildFileBase(url: URL, isAdmin: boolean): string {
  const segments = url.pathname.split('/').filter(Boolean).map((segment) => sanitizeSegment(segment));
  if (segments.length === 0) {
    segments.push('home');
  }

  const queryParts: string[] = [];
  const keys = Array.from(url.searchParams.keys()).sort();
  keys.forEach((key) => {
    const values = url.searchParams.getAll(key);
    if (values.length === 0) {
      queryParts.push(sanitizeSegment(key));
      return;
    }
    values
      .slice()
      .sort()
      .forEach((value) => {
        const sanitizedKey = sanitizeSegment(key);
        const sanitizedValue = sanitizeSegment(value || 'any');
        queryParts.push(`${sanitizedKey}-${sanitizedValue}`);
      });
  });

  const combined = [...segments, ...queryParts].join('-');
  let base = sanitizeSegment(combined || 'page');
  if (isAdmin && !base.startsWith('admin-')) {
    base = `admin-${base}`;
  }
  return base || 'page';
}

function sanitizeSegment(input: string): string {
  const normalized = input
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9]+/g, '-');
  const cleaned = normalized.replace(/^-+|-+$/g, '').toLowerCase();
  return cleaned || 'item';
}

function prepareTargets(targets: CrawlTarget[], outDir: string): PreparedTarget[] {
  const counts = new Map<string, number>();
  return targets.map((target) => {
    const current = counts.get(target.fileBase) ?? 0;
    counts.set(target.fileBase, current + 1);
    const baseName = current === 0 ? target.fileBase : `${target.fileBase}-${current + 1}`;
    const outputPath = path.join(outDir, `${baseName}.png`);
    return { ...target, outputPath };
  });
}

async function runCapture(
  targets: PreparedTarget[],
  options: CliOptions,
  baseUrl: URL
): Promise<{ saved: string[]; failed: FailureRecord[] }> {
  const browser = await puppeteer.launch({
    headless: true,
    defaultViewport: { width: 1200, height: 800 }
  });
  console.log('OK: browser launched');

  const saved: string[] = [];
  const failed: FailureRecord[] = [];
  let cursor = 0;

  const workerTotal = Math.max(1, Math.min(options.concurrency, targets.length || 1));
  console.log(`OK: workers ${workerTotal}`);

  const workers = Array.from({ length: workerTotal }, (_, workerIndex) =>
    workerLoop(browser, targets, options, baseUrl, saved, failed, () => {
      if (cursor >= targets.length) {
        return undefined;
      }
      const next = targets[cursor];
      cursor += 1;
      return next;
    },
    workerIndex)
  );

  await Promise.all(workers);
  await browser.close();
  console.log('OK: browser closed');

  return { saved, failed };
}

async function workerLoop(
  browser: Browser,
  targets: PreparedTarget[],
  options: CliOptions,
  baseUrl: URL,
  saved: string[],
  failed: FailureRecord[],
  getNext: () => PreparedTarget | undefined,
  workerIndex: number
) {
  const page = await browser.newPage();
  let loggedIn = false;

  while (true) {
    const target = getNext();
    if (!target) {
      break;
    }
    await processTarget(page, target, options, baseUrl, saved, failed, () => {
      loggedIn = false;
    }, () => loggedIn, () => {
      loggedIn = true;
      console.log(`OK: admin session worker${workerIndex + 1}`);
    });
  }

  await page.close();
}

async function processTarget(
  page: Page,
  target: PreparedTarget,
  options: CliOptions,
  baseUrl: URL,
  saved: string[],
  failed: FailureRecord[],
  resetLogin: () => void,
  isLoggedIn: () => boolean,
  markLoggedIn: () => void
) {
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt += 1) {
    try {
      if (target.isAdmin) {
        if (!options.pin) {
          throw new Error('Admin PIN is required but not provided');
        }
        if (!isLoggedIn()) {
          await performAdminLogin(page, baseUrl, options.pin);
          markLoggedIn();
        }
      }

      await captureOnce(page, target.outputPath, target.url);
      saved.push(target.outputPath);
      console.log(`Saved: ${target.outputPath}`);
      return;
    } catch (error) {
      console.error(`Capture error attempt ${attempt} for ${target.url}`);
      console.error(error);
      resetLogin();
      if (attempt < MAX_ATTEMPTS) {
        console.log(`OK: retry ${target.url} (${attempt + 1}/${MAX_ATTEMPTS})`);
        await delay(500);
        continue;
      }
      const message = error instanceof Error ? error.stack ?? error.message : String(error);
      failed.push({ url: target.url, error: message });
      break;
    }
  }
}

async function captureOnce(page: Page, outputPath: string, url: string) {
  await fs.promises.mkdir(path.dirname(outputPath), { recursive: true });
  try {
    await fs.promises.unlink(outputPath);
  } catch (error: unknown) {
    if ((error as NodeJS.ErrnoException)?.code !== 'ENOENT') {
      throw error;
    }
  }

  await page.goto(url, { waitUntil: 'networkidle0', timeout: 60_000 });
  await page.evaluate(() => {
    const style = document.createElement('style');
    style.textContent = '*{animation: none !important; transition: none !important;}';
    document.head.appendChild(style);
  });
  const screenshotPath = outputPath as `${string}.png`;
  await page.screenshot({ path: screenshotPath, fullPage: true });
}

async function performAdminLogin(page: Page, baseUrl: URL, pin: string) {
  const loginUrl = new URL('/admin/login', baseUrl).toString();
  await page.goto(loginUrl, { waitUntil: 'networkidle0', timeout: 60_000 });
  const inputSelectors = ['input[name="pin"]', 'input[type="password"]', 'input[type="text"]'];
  let filled = false;
  for (const selector of inputSelectors) {
    const handle = await page.$(selector);
    if (handle) {
      await handle.click({ clickCount: 3 });
      await handle.type(pin, { delay: 20 });
      filled = true;
      break;
    }
  }
  if (!filled) {
    throw new Error('PIN input field not found on admin login page');
  }

  const submitButton = await page.$('button[type="submit"], input[type="submit"]');
  if (submitButton) {
    await Promise.all([
      submitButton.click(),
      page.waitForNavigation({ waitUntil: 'networkidle0', timeout: 60_000 }).catch(() => undefined)
    ]);
  } else {
    await Promise.all([
      page.keyboard.press('Enter'),
      page.waitForNavigation({ waitUntil: 'networkidle0', timeout: 60_000 }).catch(() => undefined)
    ]);
  }

  const currentUrl = page.url();
  if (currentUrl.includes('/admin/login')) {
    throw new Error('Admin login did not complete');
  }
}

async function delay(ms: number) {
  await new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  console.log(`OK: base ${options.base}`);
  console.log(`OK: method ${options.method}`);
  console.log(`OK: max ${options.max}`);
  console.log(`OK: concurrency ${options.concurrency}`);
  await fs.promises.mkdir(options.out, { recursive: true });
  console.log(`OK: out ${options.out}`);

  const baseUrl = new URL(options.base);
  const discovered = await discoverTargets(baseUrl, options);
  console.log(`OK: discovered ${discovered.length}`);

  const limited = discovered.slice(0, options.max);
  if (limited.length < discovered.length) {
    console.log(`OK: limited to ${limited.length}`);
  }

  const prepared = prepareTargets(limited, options.out);

  if (prepared.length === 0) {
    console.log('OK: no targets');
    await writeFailedFile([], options.out);
    console.log('Total: 0, Saved: 0, Failed: 0');
    console.log(`Output: ${options.out}`);
    return;
  }

  const { saved, failed } = await runCapture(prepared, options, baseUrl);
  await writeFailedFile(failed, options.out);

  console.log(`Total: ${prepared.length}, Saved: ${saved.length}, Failed: ${failed.length}`);
  console.log(`Output: ${options.out}`);
}

async function writeFailedFile(entries: FailureRecord[], outDir: string) {
  const failedPath = path.join(outDir, 'failed.txt');
  if (entries.length === 0) {
    await fs.promises.writeFile(failedPath, '# No failed captures\n', 'utf8');
    return;
  }
  const lines = entries.map((entry) => `${entry.url}\t${entry.error.replace(/\s+/g, ' ').trim()}`);
  await fs.promises.writeFile(failedPath, lines.join('\n') + '\n', 'utf8');
}

main().catch((error) => {
  console.error('Unhandled error in snap-site');
  console.error(error);
  process.exitCode = 1;
});
