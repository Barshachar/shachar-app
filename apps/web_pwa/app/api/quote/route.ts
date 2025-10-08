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

const SESSION_COOKIE_NAME = process.env.SESSION_COOKIE_NAME || 'ashachar_sid';
const TITLE_TEXT = 'א.שחר • אינסטלציה סיטונאית';

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
    { key: 'index', label: '#', width: 30 },
    { key: 'name', label: 'מוצר', width: 240 },
    { key: 'sku', label: 'מק"ט', width: 80 },
    { key: 'qty', label: 'כמות', width: 60 },
    { key: 'unit', label: 'מחיר יחידה', width: 110 },
    { key: 'total', label: 'סה"כ', width: 110 }
  ] as const;

  const headerSize = 12;
  const drawHeader = () => {
    let headerX = margin;
    for (const column of columns) {
      activePage.drawText(column.label, {
        x: headerX,
        y: cursorY,
        size: headerSize,
        font: regularFont,
        color: textColor
      });
      headerX += column.width;
    }
  };

  drawHeader();

  cursorY -= headerSize + 8;

  const lineHeight = 18;
  let grandTotal = 0;

  const ensureSpace = () => {
    if (cursorY < margin + lineHeight) {
      activePage = pdfDoc.addPage();
      ({ width, height } = activePage.getSize());
      cursorY = height - margin;
      drawHeader();
      cursorY -= headerSize + 8;
    }
  };

  items.forEach((item, index) => {
    const unitPrice = item.variant.price_cents;
    const lineTotal = unitPrice * item.qty;
    grandTotal += lineTotal;

    const entries: Record<typeof columns[number]['key'], string> = {
      index: String(index + 1),
      name: item.product.name,
      sku: item.variant.sku || '—',
      qty: String(item.qty),
      unit: formatILS(unitPrice),
      total: formatILS(lineTotal)
    };

    ensureSpace();

    let currentX = margin;
    for (const column of columns) {
      const text = entries[column.key];
      const fontToUse = column.key === 'sku' ? monoFont : regularFont;
      activePage.drawText(text, {
        x: currentX,
        y: cursorY,
        size: 12,
        font: fontToUse,
        color: textColor
      });
      currentX += column.width;
    }

    cursorY -= lineHeight;
  });

  cursorY -= 10;
  ensureSpace();
  const totalLabel = `סה"כ לתשלום: ${formatILS(grandTotal)}`;
  const totalWidth = regularFont.widthOfTextAtSize(totalLabel, 14);
  activePage.drawText(totalLabel, {
    x: width - margin - totalWidth,
    y: cursorY,
    size: 14,
    font: regularFont,
    color: rgb(0.02, 0.4, 0.2)
  });

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
