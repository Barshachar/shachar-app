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
  maximumFractionDigits: 0
});

const LRM_REGEX = /\u200e/g;

function sanitizeNumberText(text: string): string {
  return text.replace(LRM_REGEX, '');
}

function formatInteger(value: number): string {
  return sanitizeNumberText(integerFormatter.format(value));
}

function formatQuantity(value: number): string {
  return sanitizeNumberText(quantityFormatter.format(value));
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

function wrapRtl(text: string): string {
  return `${RTL_EMBED_START}${text}${RTL_EMBED_END}`;
}

function assertIntegerCents(value: number, field: string): void {
  if (!Number.isInteger(value)) {
    throw new Error(`Expected ${field} to be an integer number of cents`);
  }
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

  const titleWidth = regularFont.widthOfTextAtSize(TITLE_TEXT, headingSize);
  activePage.drawText(TITLE_TEXT, {
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
  const maxMetaWidth = Math.max(
    regularFont.widthOfTextAtSize(dateLabel, dateSize),
    regularFont.widthOfTextAtSize(referenceText, dateSize)
  );
  activePage.drawText(referenceText, {
    x: width - margin - maxMetaWidth,
    y: cursorY,
    size: dateSize,
    font: regularFont,
    color: textColor
  });
  cursorY -= dateSize + 6;
  activePage.drawText(dateLabel, {
    x: width - margin - maxMetaWidth,
    y: cursorY,
    size: dateSize,
    font: regularFont,
    color: textColor
  });

  cursorY -= dateSize + 18;

  const columns = [
    {
      key: 'index',
      label: '#',
      width: 30,
      align: 'right' as const,
      wrapHeader: false,
      wrapValue: false,
      useMono: false
    },
    {
      key: 'name',
      label: 'מוצר',
      width: 240,
      align: 'right' as const,
      wrapHeader: true,
      wrapValue: true,
      useMono: false
    },
    {
      key: 'sku',
      label: 'מק"ט',
      width: 80,
      align: 'right' as const,
      wrapHeader: true,
      wrapValue: false,
      useMono: true
    },
    {
      key: 'qty',
      label: 'כמות',
      width: 60,
      align: 'right' as const,
      wrapHeader: true,
      wrapValue: false,
      useMono: false
    },
    {
      key: 'unit',
      label: 'מחיר יחידה',
      width: 110,
      align: 'right' as const,
      wrapHeader: true,
      wrapValue: false,
      useMono: false
    },
    {
      key: 'total',
      label: 'סה"כ',
      width: 110,
      align: 'right' as const,
      wrapHeader: true,
      wrapValue: false,
      useMono: false
    }
  ] as const;

  const totals = computeTotals(
    items.map((item) => ({
      qty: item.qty,
      unitPriceCents: item.variant.price_cents
    })),
    VAT_RATE
  );

  type ColumnRect = (typeof columns)[number] & {
    left: number;
    right: number;
  };

  const tableWidth = columns.reduce((acc, column) => acc + column.width, 0);
  const computeColumnRects = (): ColumnRect[] => {
    const availableLeft = Math.max(margin, width - margin - tableWidth);
    const tableRight = availableLeft + tableWidth;
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
      const textWidth = regularFont.widthOfTextAtSize(column.label, headerSize);
      const textX = column.align === 'right' ? column.right - textWidth : column.left;
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
      columnRects = computeColumnRects();
      cursorY = height - margin;
      drawHeader();
      cursorY -= headerSize + 8;
    }
  };

  items.forEach((item, index) => {
    const unitPrice = item.variant.price_cents;
    const lineTotal = Math.round(unitPrice * item.qty);

    const productName = item.product.name?.trim();
    const entries: Record<typeof columns[number]['key'], string> = {
      index: formatInteger(index + 1),
      name: productName && productName.length ? productName : '—',
      sku: item.variant.sku || '—',
      qty: formatQuantity(item.qty),
      unit: formatILS(unitPrice),
      total: formatILS(lineTotal)
    };

    ensureSpace();

    for (const column of columnRects) {
      const baseText = entries[column.key];
      const text = column.wrapValue ? wrapRtl(baseText) : baseText;
      const fontToUse = column.useMono ? monoFont : regularFont;
      const textWidth = fontToUse.widthOfTextAtSize(baseText, rowFontSize);
      const textX = column.align === 'right' ? column.right - textWidth : column.left;
      activePage.drawText(text, {
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

  assertIntegerCents(totals.subtotal, 'subtotal');
  assertIntegerCents(totals.vat, 'vat');
  assertIntegerCents(totals.total, 'total');

  cursorY -= 10;
  for (const entry of summaryEntries) {
    ensureSpace();
    const valueText = formatILS(entry.value);
    const valueWidth = regularFont.widthOfTextAtSize(valueText, entry.size);
    const valueX = width - margin - valueWidth;
    activePage.drawText(valueText, {
      x: valueX,
      y: cursorY,
      size: entry.size,
      font: regularFont,
      color: entry.color
    });

    const labelText = wrapRtl(entry.label);
    const labelWidth = regularFont.widthOfTextAtSize(entry.label, entry.size);
    const labelX = valueX - 12 - labelWidth;
    activePage.drawText(labelText, {
      x: labelX,
      y: cursorY,
      size: entry.size,
      font: regularFont,
      color: textColor
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
