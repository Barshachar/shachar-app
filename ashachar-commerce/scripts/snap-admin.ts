import fs from 'fs';
import path from 'path';
import puppeteer from 'puppeteer';
import type { Page, ScreenshotOptions } from 'puppeteer';

type CliOptions = {
  url: string;
  out: string;
  pin?: string;
};

function parseArgs(argv: string[]): CliOptions {
  const options: Partial<CliOptions> = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) {
      continue;
    }
    const key = arg.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      continue;
    }
    (options as Record<string, string>)[key] = next;
    i += 1;
  }

  if (!options.url) {
    throw new Error('Missing required flag: --url');
  }
  if (!options.out) {
    throw new Error('Missing required flag: --out');
  }

  return options as CliOptions;
}

async function ensureDirectory(filePath: string) {
  const dir = path.dirname(filePath);
  await fs.promises.mkdir(dir, { recursive: true });
}

async function performLogin(page: Page, targetUrl: URL, pin: string) {
  const loginUrl = new URL('/admin/login', targetUrl.origin).toString();
  await page.goto(loginUrl, { waitUntil: 'networkidle0' });
  await page.type('input[name="pin"]', pin, { delay: 50 });
  await Promise.all([
    page.click('button[type="submit"]'),
    page.waitForNavigation({ waitUntil: 'networkidle0' })
  ]);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const targetUrl = new URL(args.url);
  const outputPath = path.resolve(args.out);

  if (!outputPath.toLowerCase().endsWith('.png')) {
    throw new Error('Output file must use a .png extension');
  }

  await ensureDirectory(outputPath);

  const browser = await puppeteer.launch({
    headless: true,
    defaultViewport: { width: 1200, height: 800 }
  });

  try {
    const page = await browser.newPage();
    if (args.pin) {
      await performLogin(page, targetUrl, args.pin);
    }

    await page.goto(targetUrl.toString(), { waitUntil: 'networkidle0' });
    await page.screenshot({
      path: outputPath as ScreenshotOptions['path'],
      fullPage: true
    });
    console.log(`Saved: ${outputPath}`);
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
