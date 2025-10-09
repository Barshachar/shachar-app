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

const quantityFormatter = new Intl.NumberFormat('he-IL', {
  maximumFractionDigits: 3,
  minimumFractionDigits: 0
});

const integerFormatter = new Intl.NumberFormat('he-IL', {
  maximumFractionDigits: 0,
  minimumFractionDigits: 0,
  useGrouping: false
});

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
    { key: 'index', label: '#', width: 36, align: 'right' as const },
    { key: 'name', label: 'מוצר', width: 180, align: 'right' as const },
    { key: 'sku', label: 'מק"ט', width: 90, align: 'left' as const },
    { key: 'qty', label: 'כמות', width: 70, align: 'right' as const },
    { key: 'unit', label: 'מחיר יחידה', width: 80, align: 'right' as const },
    { key: 'total', label: 'סה"כ', width: 80, align: 'right' as const }
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
      const textWidth = regularFont.widthOfTextAtSize(column.label, headerSize);
      const textX = column.align === 'right' ? column.right - textWidth : column.left;
      activePage.drawText(column.label, {
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

    const entries: Record<typeof columns[number]['key'], string> = {
      index: integerFormatter.format(index + 1),
      name: item.product.name,
      sku: item.variant.sku || '—',
      qty: quantityFormatter.format(item.qty),
      unit: formatILS(Math.round(unitPrice)),
      total: formatILS(lineTotal)
    };

    ensureSpace();

    for (const column of columnRects) {
      const text = entries[column.key];
      const fontToUse = column.key === 'sku' ? monoFont : regularFont;
      const textWidth = fontToUse.widthOfTextAtSize(text, rowFontSize);
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

  const vatPercentText = new Intl.NumberFormat('he-IL', {
    maximumFractionDigits: 2,
    minimumFractionDigits: 0
  }).format(VAT_RATE * 100);

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

  cursorY -= 10;
  for (const entry of summaryEntries) {
    ensureSpace();
    const valueText = formatILS(Math.round(entry.value));
    const valueWidth = regularFont.widthOfTextAtSize(valueText, entry.size);
    const valueX = width - margin - valueWidth;
    activePage.drawText(valueText, {
      x: valueX,
      y: cursorY,
      size: entry.size,
      font: regularFont,
      color: entry.color
    });

    const labelWidth = regularFont.widthOfTextAtSize(entry.label, entry.size);
    const labelX = valueX - 12 - labelWidth;
    activePage.drawText(entry.label, {
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
