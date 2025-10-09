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
import { computeTotals, type QuoteTotals } from '@/lib/quote';
import { sanitizeNumberText, stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';

const SESSION_COOKIE_NAME = process.env.SESSION_COOKIE_NAME || 'ashachar_sid';
const TITLE_TEXT = 'א.שחר • אינסטלציה סיטונאית';
const VAT_RATE = 0.17;
const PRIMARY_TEXT_COLOR = rgb(0.1, 0.1, 0.1);
const SUMMARY_HIGHLIGHT_COLOR = rgb(0.02, 0.4, 0.2);
const VAT_PERCENT_FORMATTER = new Intl.NumberFormat('he-IL', {
  maximumFractionDigits: 2,
  minimumFractionDigits: 0
});

const MODULE_DIR = path.dirname(fileURLToPath(import.meta.url));

const quantityFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 3
});

const integerFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 0
});

function formatInteger(value: number): string {
  return sanitizeNumberText(integerFormatter.format(value));
}

function formatQuantity(value: number): string {
  return sanitizeNumberText(quantityFormatter.format(value));
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

export const NUMERIC_COLUMN_KEYS: ReadonlySet<ColumnKey> = new Set([
  'index',
  'qty',
  'unit',
  'total'
]);

export const TABLE_COLUMN_ORDER = [
  'index',
  'name',
  'sku',
  'qty',
  'unit',
  'total'
] as const satisfies ReadonlyArray<ColumnKey>;

const TABLE_COLUMN_CONFIG: { [Key in ColumnKey]: Omit<ColumnDefinition, 'key'> } = {
  index: {
    label: '#',
    width: 26,
    align: 'right',
    wrapHeader: false,
    wrapValue: false,
    useMono: true
  },
  name: {
    label: 'מוצר',
    width: 200,
    align: 'right',
    wrapHeader: true,
    wrapValue: true,
    useMono: false
  },
  sku: {
    label: 'מק"ט',
    width: 84,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  qty: {
    label: 'כמות',
    width: 52,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  unit: {
    label: 'מחיר יחידה',
    width: 75,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  },
  total: {
    label: 'סה"כ',
    width: 75,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  }
} as const satisfies { [Key in ColumnKey]: Omit<ColumnDefinition, 'key'> };

export const TABLE_COLUMNS: ReadonlyArray<ColumnDefinition> = TABLE_COLUMN_ORDER.map(
  (key) => ({
    key,
    ...TABLE_COLUMN_CONFIG[key]
  })
);

export function validateTableColumns(columns: ReadonlyArray<ColumnDefinition>): void {
  const keys = columns.map((column) => column.key);
  if (
    keys.length !== TABLE_COLUMN_ORDER.length ||
    keys.some((key, index) => key !== TABLE_COLUMN_ORDER[index])
  ) {
    throw new Error('TABLE_COLUMNS must preserve the expected RTL column order');
  }

  for (const column of columns) {
    if (NUMERIC_COLUMN_KEYS.has(column.key)) {
      if (column.align !== 'right') {
        throw new Error(`Numeric column ${column.key} must be right-aligned`);
      }
      if (column.wrapValue) {
        throw new Error(`Numeric column ${column.key} must not wrap values`);
      }
    }
  }
}

validateTableColumns(TABLE_COLUMNS);

export type ColumnRect = ColumnDefinition & {
  left: number;
  right: number;
};

type ColumnPlacement = Pick<ColumnRect, 'align' | 'left' | 'right'>;

export function resolveColumnTextX(
  column: ColumnPlacement,
  text: string,
  font: PDFFont,
  size: number
): number {
  if (column.align === 'right') {
    return getRightAlignedX(text, font, size, column.right);
  }
  return column.left;
}

export function computeColumnRectsForWidth(
  pageWidth: number,
  margin: number,
  columns: ReadonlyArray<ColumnDefinition> = TABLE_COLUMNS
): ColumnRect[] {
  if (!Number.isFinite(pageWidth) || pageWidth <= 0) {
    throw new Error('pageWidth must be a positive finite number');
  }
  if (!Number.isFinite(margin) || margin < 0) {
    throw new Error('margin must be a non-negative finite number');
  }

  const tableWidth = columns.reduce((acc, column) => acc + column.width, 0);
  const idealRight = Math.max(pageWidth - margin, 0);
  const tableLeft = Math.max(0, idealRight - tableWidth);
  const tableRight = tableLeft + tableWidth;
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
}

export function resolveTableRightEdge(
  columnRects: ReadonlyArray<ColumnRect>,
  pageWidth: number,
  margin: number
): number {
  if (columnRects.length > 0) {
    return columnRects[0]!.right;
  }
  if (!Number.isFinite(pageWidth) || pageWidth <= 0) {
    throw new Error('pageWidth must be a positive finite number');
  }
  if (!Number.isFinite(margin) || margin < 0) {
    throw new Error('margin must be a non-negative finite number');
  }
  return Math.max(pageWidth - margin, 0);
}

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

function getRightAlignedX(text: string, font: PDFFont, size: number, rightEdge: number): number {
  return rightEdge - font.widthOfTextAtSize(stripDirectionalMarkers(text), size);
}

function assertIntegerCents(value: number, field: string): void {
  if (!Number.isInteger(value)) {
    throw new Error(`Expected ${field} to be an integer number of cents`);
  }
}

export function formatCurrencyForPdf(valueCents: number, field: string): string {
  assertIntegerCents(valueCents, field);
  const sanitized = sanitizeNumberText(formatILS(valueCents));
  return wrapRtl(sanitized);
}

type SummaryEntryKey = keyof QuoteTotals;

type SummaryEntryDefinition = {
  key: SummaryEntryKey;
  buildLabel: (vatPercentText: string) => string;
  fontSize: number;
  valueColor: RGB;
};

const SUMMARY_ENTRY_DEFINITIONS: readonly SummaryEntryDefinition[] = [
  {
    key: 'subtotal',
    buildLabel: () => 'סכום ביניים',
    fontSize: 12,
    valueColor: PRIMARY_TEXT_COLOR
  },
  {
    key: 'vat',
    buildLabel: (vatPercentText) => `מע"מ (${vatPercentText}%)`,
    fontSize: 12,
    valueColor: PRIMARY_TEXT_COLOR
  },
  {
    key: 'total',
    buildLabel: () => 'סה"כ לתשלום',
    fontSize: 14,
    valueColor: SUMMARY_HIGHLIGHT_COLOR
  }
] as const satisfies ReadonlyArray<SummaryEntryDefinition>;

export type SummaryTextEntry = {
  key: SummaryEntryKey;
  labelText: string;
  valueText: string;
  fontSize: number;
  valueColor: RGB;
};

export function buildSummaryTextEntries(
  totals: QuoteTotals,
  vatRate: number
): SummaryTextEntry[] {
  if (!Number.isFinite(vatRate)) {
    throw new Error('VAT rate must be a finite number');
  }
  if (vatRate < 0) {
    throw new Error('VAT rate must be non-negative');
  }

  const vatPercentText = sanitizeNumberText(
    VAT_PERCENT_FORMATTER.format(vatRate * 100)
  );

  return SUMMARY_ENTRY_DEFINITIONS.map((definition) => {
    const rawLabel = definition.buildLabel(vatPercentText);
    const labelText = wrapRtl(rawLabel);
    const valueText = formatCurrencyForPdf(totals[definition.key], rawLabel);
    return {
      key: definition.key,
      labelText,
      valueText,
      fontSize: definition.fontSize,
      valueColor: definition.valueColor
    };
  });
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
  const textColor = PRIMARY_TEXT_COLOR;

  const rtlTitleText = wrapRtl(TITLE_TEXT);
  const titleWidth = regularFont.widthOfTextAtSize(rtlTitleText, headingSize);
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
    regularFont.widthOfTextAtSize(rtlDateLabel, dateSize),
    regularFont.widthOfTextAtSize(rtlReferenceText, dateSize)
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

  const totals = computeTotals(
    items.map((item) => ({
      qty: item.qty,
      unitPriceCents: item.variant.price_cents
    })),
    VAT_RATE
  );

  const headerSize = 12;
  let columnRects = computeColumnRectsForWidth(width, margin);
  const drawHeader = () => {
    columnRects = computeColumnRectsForWidth(width, margin);
    for (const column of columnRects) {
      const headerText = column.wrapHeader ? wrapRtl(column.label) : column.label;
      const textX = resolveColumnTextX(column, headerText, regularFont, headerSize);
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
      columnRects = computeColumnRectsForWidth(width, margin);
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
      const textX = resolveColumnTextX(column, displayText, fontToUse, rowFontSize);
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

  assertIntegerCents(totals.subtotal, 'subtotal');
  assertIntegerCents(totals.vat, 'VAT amount');
  assertIntegerCents(totals.total, 'total');

  const summaryEntries = buildSummaryTextEntries(totals, VAT_RATE);

  const ensureSummarySpace = (requiredHeight: number) => {
    if (cursorY < margin + requiredHeight) {
      activePage = pdfDoc.addPage();
      ({ width, height } = activePage.getSize());
      columnRects = computeColumnRectsForWidth(width, margin);
      cursorY = height - margin;
    }
  };

  const summaryGap = 16;
  cursorY -= 10;
  for (const entry of summaryEntries) {
    const lineSpacing = entry.fontSize === 14 ? 20 : 16;
    ensureSummarySpace(lineSpacing);
    const tableRightEdge = resolveTableRightEdge(columnRects, width, margin);
    const valueX = getRightAlignedX(entry.valueText, regularFont, entry.fontSize, tableRightEdge);
    activePage.drawText(entry.valueText, {
      x: valueX,
      y: cursorY,
      size: entry.fontSize,
      font: regularFont,
      color: entry.valueColor
    });

    const labelRightEdge = Math.max(valueX - summaryGap, margin);
    const labelX = getRightAlignedX(
      entry.labelText,
      regularFont,
      entry.fontSize,
      labelRightEdge
    );
    activePage.drawText(entry.labelText, {
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
