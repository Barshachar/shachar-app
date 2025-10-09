import { NextResponse } from 'next/server';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';
import { Buffer } from 'node:buffer';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import type { PDFFont, RGB } from 'pdf-lib';
import fontkit from '@pdf-lib/fontkit';
import { fetchCartItems } from '@/lib/data';
import { formatILS } from '@/lib/formatter';
import { assertLocalMode } from '@/lib/admin/local-mode';
import { computeTotals } from '@/lib/quote';
import type { QuoteTotals } from '@/lib/quote';

const SESSION_COOKIE_NAME = process.env.SESSION_COOKIE_NAME || 'ashachar_sid';
const TITLE_TEXT = 'א.שחר • אינסטלציה סיטונאית';
const VAT_RATE = 0.17;
const RTL_EMBED_START = '\u202B';
const RTL_EMBED_END = '\u202C';

const quantityFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 3
});

const integerFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
  useGrouping: false
});

const VAT_PERCENT_FORMATTER = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 2
});

const DIRECTIONAL_MARKS_REGEX = /[\u200e\u200f\u202a-\u202e\u2066-\u2069]/g;

function stripDirectionalMarkers(text: string): string {
  return text.replace(DIRECTIONAL_MARKS_REGEX, '');
}

function sanitizeNumberText(text: string): string {
  return stripDirectionalMarkers(text);
}

export function formatInteger(value: number): string {
  return sanitizeNumberText(integerFormatter.format(value));
}

export function formatQuantity(value: number): string {
  return sanitizeNumberText(quantityFormatter.format(value));
}

function wrapRtl(text: string): string {
  return `${RTL_EMBED_START}${text}${RTL_EMBED_END}`;
}

function measureTextWidth(text: string, font: PDFFont, size: number): number {
  return font.widthOfTextAtSize(stripDirectionalMarkers(text), size);
}

function getRightAlignedX(text: string, font: PDFFont, size: number, rightEdge: number): number {
  return rightEdge - measureTextWidth(text, font, size);
}

function assertIntegerCents(value: number, field: string): void {
  if (!Number.isInteger(value)) {
    throw new Error(`Expected ${field} to be an integer number of cents`);
  }
}

type ColumnKey = 'index' | 'name' | 'sku' | 'qty' | 'unit' | 'total';
type ColumnAlignment = 'left' | 'right';
type ColumnDefinition = {
  key: ColumnKey;
  label: string;
  width: number;
  align: ColumnAlignment;
  wrapHeader: boolean;
  wrapValue: boolean;
  useMono: boolean;
};

const RTL_COLUMN_ORDER: readonly ColumnKey[] = [
  'index',
  'name',
  'sku',
  'qty',
  'unit',
  'total'
] as const;

export const NUMERIC_COLUMN_KEYS: ReadonlySet<ColumnKey> = new Set([
  'index',
  'qty',
  'unit',
  'total'
]);

const BASE_COLUMN_DEFINITIONS: Record<
  ColumnKey,
  Omit<ColumnDefinition, 'key'>
> = {
  index: {
    label: '#',
    width: 32,
    align: 'right',
    wrapHeader: false,
    wrapValue: false,
    useMono: true
  },
  name: {
    label: 'מוצר',
    width: 198,
    align: 'right',
    wrapHeader: true,
    wrapValue: true,
    useMono: false
  },
  sku: {
    label: 'מק"ט',
    width: 70,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  qty: {
    label: 'כמות',
    width: 55,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  unit: {
    label: 'מחיר יחידה',
    width: 76,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  },
  total: {
    label: 'סה"כ',
    width: 88,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  }
};

export const TABLE_COLUMNS = RTL_COLUMN_ORDER.map((key) => ({
  key,
  ...BASE_COLUMN_DEFINITIONS[key]
})) as const satisfies ReadonlyArray<ColumnDefinition>;

export type ColumnRect = ColumnDefinition & {
  left: number;
  right: number;
};

export function resolveTableRightEdge(
  columnRects: ReadonlyArray<ColumnRect>,
  pageWidth: number,
  margin: number
): number {
  if (columnRects.length > 0) {
    return columnRects[0].right;
  }
  if (!Number.isFinite(pageWidth) || pageWidth <= 0) {
    throw new Error('pageWidth must be a positive finite number');
  }
  if (!Number.isFinite(margin) || margin < 0) {
    throw new Error('margin must be a non-negative finite number');
  }
  return Math.max(pageWidth - margin, 0);
}

export function formatCurrencyForPdf(valueCents: number, field: string): string {
  assertIntegerCents(valueCents, field);
  const sanitized = sanitizeNumberText(formatILS(valueCents));
  return wrapRtl(sanitized);
}

export type QuoteSummaryRowKey = 'subtotal' | 'vat' | 'total';

export type QuoteSummaryRow = {
  key: QuoteSummaryRowKey;
  label: string;
  value: string;
  size: number;
};

export function prepareSummaryRows(
  totals: QuoteTotals,
  vatRate: number
): ReadonlyArray<QuoteSummaryRow> {
  if (!Number.isFinite(vatRate)) {
    throw new Error('VAT rate must be a finite number for summary rows');
  }
  if (vatRate < 0) {
    throw new Error('VAT rate must be non-negative for summary rows');
  }

  assertIntegerCents(totals.subtotal, 'summary subtotal');
  assertIntegerCents(totals.vat, 'summary VAT');
  assertIntegerCents(totals.total, 'summary total');

  if (totals.total !== totals.subtotal + totals.vat) {
    throw new Error('Summary total must equal subtotal plus VAT');
  }

  const vatPercentText = sanitizeNumberText(VAT_PERCENT_FORMATTER.format(vatRate * 100));

  return [
    {
      key: 'subtotal',
      label: wrapRtl('סכום ביניים'),
      value: formatCurrencyForPdf(totals.subtotal, 'summary subtotal'),
      size: 12
    },
    {
      key: 'vat',
      label: wrapRtl(`מע"מ (${vatPercentText}%)`),
      value: formatCurrencyForPdf(totals.vat, 'summary VAT'),
      size: 12
    },
    {
      key: 'total',
      label: wrapRtl('סה"כ לתשלום'),
      value: formatCurrencyForPdf(totals.total, 'summary total'),
      size: 14
    }
  ] satisfies ReadonlyArray<QuoteSummaryRow>;
}

type SummaryKey = 'subtotal' | 'vat' | 'total';

export type SummaryEntry = {
  key: SummaryKey;
  label: string;
  cents: number;
  fontSize: number;
  color: RGB;
};

export function buildSummaryEntries(
  totals: QuoteTotals,
  vatRate: number,
  baseTextColor: RGB,
  totalHighlightColor: RGB
): ReadonlyArray<SummaryEntry> {
  assertIntegerCents(totals.subtotal, 'summary subtotal cents');
  assertIntegerCents(totals.vat, 'summary vat cents');
  assertIntegerCents(totals.total, 'summary total cents');

  if (!Number.isFinite(vatRate) || vatRate < 0) {
    throw new Error('vatRate must be a non-negative finite number');
  }

  const vatPercentText = sanitizeNumberText(
    new Intl.NumberFormat('he-IL', {
      maximumFractionDigits: 2,
      minimumFractionDigits: 0
    }).format(vatRate * 100)
  );

  return [
    {
      key: 'subtotal',
      label: 'סכום ביניים',
      cents: totals.subtotal,
      fontSize: 12,
      color: baseTextColor
    },
    {
      key: 'vat',
      label: `מע"מ (${vatPercentText}%)`,
      cents: totals.vat,
      fontSize: 12,
      color: baseTextColor
    },
    {
      key: 'total',
      label: 'סה"כ לתשלום',
      cents: totals.total,
      fontSize: 14,
      color: totalHighlightColor
    }
  ];
}

const MODULE_DIR = path.dirname(fileURLToPath(import.meta.url));

const DEFAULT_FONT_PATH = path.resolve(MODULE_DIR, 'fonts', 'Inter-Regular.ttf');

let cachedFontBytes: Uint8Array | null | undefined;

async function tryLoadFontBytes(): Promise<Uint8Array | null> {
  if (cachedFontBytes !== undefined) {
    return cachedFontBytes;
  }

  const candidatePaths: string[] = [];
  if (process.env.PDF_FONT_PATH) {
    candidatePaths.push(path.resolve(process.env.PDF_FONT_PATH));
  }
  candidatePaths.push(DEFAULT_FONT_PATH);
  candidatePaths.push(
    path.resolve(process.cwd(), 'app', 'api', 'quote', 'fonts', 'Inter-Regular.ttf')
  );
  candidatePaths.push(
    path.resolve(MODULE_DIR, '../../..', 'public', 'fonts', 'NotoSansHebrew.ttf')
  );
  candidatePaths.push(
    path.resolve(process.cwd(), 'public', 'fonts', 'NotoSansHebrew.ttf')
  );

  for (const candidatePath of candidatePaths) {
    try {
      const stats = await fs.stat(candidatePath);
      if (!stats.isFile() || stats.size === 0) {
        continue;
      }

      const buffer = await fs.readFile(candidatePath);
      if (buffer.length === 0) {
        continue;
      }

      const bytes = new Uint8Array(
        buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength)
      );

      cachedFontBytes = bytes;
      return bytes;
    } catch {
      continue;
    }
  }

  cachedFontBytes = null;
  return null;
}

function parseSessionId(request: Request): string | null {
  const cookieHeader = request.headers.get('cookie');
  if (!cookieHeader) {
    return null;
  }
  const entries = cookieHeader.split(';');
  for (const entry of entries) {
    const [rawName, ...rest] = entry.trim().split('=');
    if (!rawName || rest.length === 0) {
      continue;
    }
    if (rawName === SESSION_COOKIE_NAME) {
      return decodeURIComponent(rest.join('='));
    }
  }
  return null;
}

function formatDate(): string {
  return new Intl.DateTimeFormat('he-IL', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(new Date());
}

export async function POST(request: Request) {
  try {
    assertLocalMode();
  } catch (response) {
    return response as Response;
  }

  const sessionId = parseSessionId(request);
  if (!sessionId) {
    return NextResponse.json({ error: 'Cart session not found' }, { status: 400 });
  }

  const items = await fetchCartItems(sessionId);
  if (!items.length) {
    return NextResponse.json({ error: 'Cart is empty' }, { status: 400 });
  }

  const pdfDoc = await PDFDocument.create();

  const regularFontBytes = await tryLoadFontBytes();
  let regularFont: PDFFont;
  if (regularFontBytes) {
    pdfDoc.registerFontkit(fontkit);
    regularFont = await pdfDoc.embedFont(regularFontBytes, { subset: true });
  } else {
    regularFont = await pdfDoc.embedFont(StandardFonts.Helvetica);
  }
  const monoFont = await pdfDoc.embedFont(StandardFonts.Courier);

  let activePage = pdfDoc.addPage();
  const margin = 50;
  let { width, height } = activePage.getSize();
  let cursorY = height - margin;

  const headingSize = 20;
  const dateSize = 12;
  const textColor = rgb(0.1, 0.1, 0.1);
  const totalHighlightColor = rgb(0.02, 0.4, 0.2);

  const rtlTitleText = wrapRtl(TITLE_TEXT);
  const titleWidth = measureTextWidth(rtlTitleText, regularFont, headingSize);
  activePage.drawText(rtlTitleText, {
    x: width - margin - titleWidth,
    y: cursorY,
    size: headingSize,
    font: regularFont,
    color: textColor
  });

  cursorY -= headingSize + 12;
  const dateLabel = `נוצר בתאריך: ${formatDate()}`;
  const quoteId = randomUUID().slice(0, 8);
  const referenceText = `מספר הצעה: ${quoteId}`;
  const rtlDateLabel = wrapRtl(dateLabel);
  const rtlReferenceText = wrapRtl(referenceText);
  const maxMetaWidth = Math.max(
    measureTextWidth(rtlDateLabel, regularFont, dateSize),
    measureTextWidth(rtlReferenceText, regularFont, dateSize)
  );
  activePage.drawText(rtlReferenceText, {
    x: width - margin - maxMetaWidth,
    y: cursorY,
    size: dateSize,
    font: regularFont,
    color: textColor
  });
  cursorY -= dateSize + 6;
  activePage.drawText(rtlDateLabel, {
    x: width - margin - maxMetaWidth,
    y: cursorY,
    size: dateSize,
    font: regularFont,
    color: textColor
  });

  cursorY -= dateSize + 18;

  const columns = TABLE_COLUMNS;

  const totals = computeTotals(
    items.map((item) => ({
      qty: item.qty,
      unitPriceCents: item.variant.price_cents
    })),
    VAT_RATE
  );

  const tableWidth = columns.reduce((acc, column) => acc + column.width, 0);
  const computeColumnRects = (): ColumnRect[] => {
    const tableRight = width - margin;
    let currentRight = tableRight;

    return columns.map((column) => {
      const left = currentRight - column.width;
      const rect: ColumnRect = {
        ...column,
        left,
        right: currentRight
      };
      currentRight = left;
      return rect;
    });
  };

  const headerSize = 12;
  let columnRects = computeColumnRects();
  const drawHeader = () => {
    columnRects = computeColumnRects();
    for (const column of columnRects) {
      const headerText = column.wrapHeader ? wrapRtl(column.label) : column.label;
      const textX =
        column.align === 'right'
          ? getRightAlignedX(headerText, regularFont, headerSize, column.right)
          : column.left;
      activePage.drawText(headerText, {
        x: textX,
        y: cursorY,
        size: headerSize,
        font: regularFont,
        color: textColor
      });
    }
  };

  drawHeader();

  cursorY -= headerSize + 8;

  const lineHeight = 18;
  const rowFontSize = 12;

  const ensureRowSpace = () => {
    if (cursorY < margin + lineHeight) {
      activePage = pdfDoc.addPage();
      ({ width, height } = activePage.getSize());
      columnRects = computeColumnRects();
      cursorY = height - margin;
      drawHeader();
      cursorY -= headerSize + 8;
    }
  };

  items.forEach((item, index) => {
    const unitPriceCents = Number(item.variant.price_cents);
    assertIntegerCents(unitPriceCents, 'unit price cents');
    const lineTotalCents = Math.round(unitPriceCents * item.qty);
    assertIntegerCents(lineTotalCents, 'line total cents');

    const productName = item.product.name?.trim();
    const entries: Record<ColumnKey, string> = {
      index: formatInteger(index + 1),
      name: productName && productName.length ? productName : '—',
      sku: item.variant.sku || '—',
      qty: formatQuantity(item.qty),
      unit: formatCurrencyForPdf(unitPriceCents, 'unit price'),
      total: formatCurrencyForPdf(lineTotalCents, 'line total')
    };

    ensureRowSpace();

    for (const column of columnRects) {
      const baseText = entries[column.key];
      const displayText = column.wrapValue ? wrapRtl(baseText) : baseText;
      const fontToUse = column.useMono ? monoFont : regularFont;
      const textX =
        column.align === 'right'
          ? getRightAlignedX(displayText, fontToUse, rowFontSize, column.right)
          : column.left;
      activePage.drawText(displayText, {
        x: textX,
        y: cursorY,
        size: rowFontSize,
        font: fontToUse,
        color: textColor
      });
    }

    cursorY -= lineHeight;
  });

  const summaryEntries = buildSummaryEntries(totals, VAT_RATE, textColor, totalHighlightColor);

  const ensureSummarySpace = (requiredHeight: number) => {
    if (cursorY < margin + requiredHeight) {
      activePage = pdfDoc.addPage();
      ({ width, height } = activePage.getSize());
      columnRects = computeColumnRects();
      cursorY = height - margin;
    }
  };

  const summaryGap = 16;
  cursorY -= 10;
  for (const entry of summaryEntries) {
    const lineSpacing = entry.fontSize === 14 ? 20 : 16;
    ensureSummarySpace(lineSpacing);
    const tableRightEdge = resolveTableRightEdge(columnRects, width, margin);
    const valueText = formatCurrencyForPdf(entry.cents, entry.key);
    const valueX = getRightAlignedX(valueText, regularFont, entry.fontSize, tableRightEdge);
    activePage.drawText(valueText, {
      x: valueX,
      y: cursorY,
      size: entry.fontSize,
      font: regularFont,
      color: entry.color
    });

    const labelText = wrapRtl(entry.label);
    const labelRightEdge = Math.max(valueX - summaryGap, margin);
    const labelX = getRightAlignedX(labelText, regularFont, entry.fontSize, labelRightEdge);
    activePage.drawText(labelText, {
      x: labelX,
      y: cursorY,
      size: entry.fontSize,
      font: regularFont,
      color: textColor
    });

    cursorY -= lineSpacing;
  }

  const pdfBytes = await pdfDoc.save();
  const pdfBuffer = Buffer.from(pdfBytes);

  return new NextResponse(pdfBuffer, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="quote-${quoteId}.pdf"`
    }
  });
}

export async function GET() {
  return NextResponse.json({ error: 'Method not allowed' }, { status: 405 });
}
