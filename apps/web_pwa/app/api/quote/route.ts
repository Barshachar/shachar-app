import { NextResponse } from 'next/server';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import { Buffer } from 'node:buffer';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import type { PDFFont } from 'pdf-lib';
import fontkit from '@pdf-lib/fontkit';
import { fetchCartItems } from '@/lib/data';
import { formatILS } from '@/lib/formatter';
import { assertLocalMode } from '@/lib/admin/local-mode';
import { computeTotals } from '@/lib/quote';
import { sanitizeNumberText, stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';

const SESSION_COOKIE_NAME = process.env.SESSION_COOKIE_NAME || 'ashachar_sid';
const TITLE_TEXT = 'א.שחר • אינסטלציה סיטונאית';
const VAT_RATE = 0.17;

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

export const TABLE_COLUMNS = [
  {
    key: 'index',
    label: '#',
    width: 26,
    align: 'right',
    wrapHeader: false,
    wrapValue: false,
    useMono: true
  },
  {
    key: 'name',
    label: 'מוצר',
    width: 200,
    align: 'right',
    wrapHeader: true,
    wrapValue: true,
    useMono: false
  },
  {
    key: 'sku',
    label: 'מק"ט',
    width: 84,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  {
    key: 'qty',
    label: 'כמות',
    width: 52,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: true
  },
  {
    key: 'unit',
    label: 'מחיר יחידה',
    width: 75,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  },
  {
    key: 'total',
    label: 'סה"כ',
    width: 75,
    align: 'right',
    wrapHeader: true,
    wrapValue: false,
    useMono: false
  }
] as const satisfies ReadonlyArray<ColumnDefinition>;

type ColumnRect = ColumnDefinition & {
  left: number;
  right: number;
};

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

const DEFAULT_FONT_PATH = path.resolve(
  process.cwd(),
  'app',
  'api',
  'quote',
  'fonts',
  'Inter-Regular.ttf'
);

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
      const textX = getRightAlignedX(headerText, regularFont, headerSize, column.right);
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

  const ensureSpace = () => {
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
    const unitPrice = Number(item.variant.price_cents);
    const lineTotal = Math.round(unitPrice * item.qty);

    const productName = item.product.name?.trim();
    const entries: Record<ColumnKey, string> = {
      index: formatInteger(index + 1),
      name: productName && productName.length ? productName : '—',
      sku: item.variant.sku || '—',
      qty: formatQuantity(item.qty),
      unit: formatCurrencyForPdf(unitPrice, 'unit price'),
      total: formatCurrencyForPdf(lineTotal, 'line total')
    };

    ensureSpace();

    for (const column of columnRects) {
      const baseText = entries[column.key];
      const displayText = column.wrapValue ? wrapRtl(baseText) : baseText;
      const fontToUse = column.useMono ? monoFont : regularFont;
      const textX = getRightAlignedX(displayText, fontToUse, rowFontSize, column.right);
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

  const vatPercentText = sanitizeNumberText(
    new Intl.NumberFormat('he-IL', {
      maximumFractionDigits: 2,
      minimumFractionDigits: 0
    }).format(VAT_RATE * 100)
  );

  const summaryEntries = [
    { label: 'סכום ביניים', value: totals.subtotal, size: 12, color: textColor },
    {
      label: `מע"מ (${vatPercentText}%)`,
      value: totals.vat,
      size: 12,
      color: textColor
    },
    { label: 'סה"כ לתשלום', value: totals.total, size: 14, color: rgb(0.02, 0.4, 0.2) }
  ];

  const summaryGap = 16;
  cursorY -= 10;
  for (const entry of summaryEntries) {
    ensureSpace();
    const labelText = wrapRtl(entry.label);
    const labelRightEdge = columnRects[0]?.right ?? width - margin;
    const labelX = getRightAlignedX(labelText, regularFont, entry.size, labelRightEdge);
    activePage.drawText(labelText, {
      x: labelX,
      y: cursorY,
      size: entry.size,
      font: regularFont,
      color: textColor
    });

    const valueText = formatCurrencyForPdf(entry.value, entry.label);
    const valueRightEdge = labelX - summaryGap;
    const valueX = getRightAlignedX(valueText, regularFont, entry.size, valueRightEdge);
    activePage.drawText(valueText, {
      x: valueX,
      y: cursorY,
      size: entry.size,
      font: regularFont,
      color: entry.color
    });

    cursorY -= entry.size === 14 ? 20 : 16;
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
