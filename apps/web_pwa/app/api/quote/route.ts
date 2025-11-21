import { NextResponse } from 'next/server';
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomUUID } from 'node:crypto';
import { Buffer } from 'node:buffer';
import { PDFDocument, StandardFonts } from 'pdf-lib';
import type { PDFFont } from 'pdf-lib';
import fontkit from '@pdf-lib/fontkit';
import { fetchCartItems } from '@/lib/data';
import { assertLocalMode } from '@/lib/local-mode';
import { computeTotals } from '@/lib/quote';
import { wrapRtl } from '@/lib/pdf/rtl';
import {
  PRIMARY_TEXT_COLOR,
  assertIntegerCents,
  buildSummaryTextEntries,
  buildTableRowEntries,
  computeColumnRectsForWidth,
  getRightAlignedX,
  measureTextWidth,
  resolveColumnTextX,
  resolveTableRightEdge
} from './pdf-helpers';

const SESSION_COOKIE_NAME = process.env.SESSION_COOKIE_NAME || 'ashachar_sid';
const TITLE_TEXT = 'א.שחר • אינסטלציה סיטונאית';
const VAT_RATE = 0.17;
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
  const textColor = PRIMARY_TEXT_COLOR;

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

  const normalizedItems = items.map((item) => {
    const qty = Number(item.qty);
    const unitPriceCents = Number(item.variant.price_cents);
    return {
      original: item,
      qty,
      unitPriceCents
    };
  });

  const totals = computeTotals(
    normalizedItems.map(({ qty, unitPriceCents }) => ({
      qty,
      unitPriceCents
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

  normalizedItems.forEach(({ original: item, qty, unitPriceCents }, index) => {
    const entries = buildTableRowEntries({
      index,
      qty,
      unitPriceCents,
      productName: item.product.name,
      sku: item.variant.sku
    });

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
    const labelX = getRightAlignedX(entry.labelText, regularFont, entry.fontSize, tableRightEdge);
    activePage.drawText(entry.labelText, {
      x: labelX,
      y: cursorY,
      size: entry.fontSize,
      font: regularFont,
      color: textColor
    });

    const valueRightEdge = Math.max(labelX - summaryGap, margin);
    const valueX = getRightAlignedX(
      entry.valueText,
      regularFont,
      entry.fontSize,
      valueRightEdge
    );
    activePage.drawText(entry.valueText, {
      x: valueX,
      y: cursorY,
      size: entry.fontSize,
      font: regularFont,
      color: entry.valueColor
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
