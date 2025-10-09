import { rgb, type PDFFont, type RGB } from 'pdf-lib';
import { formatILS } from '@/lib/formatter';
import { computeLineTotalCents, type QuoteTotals } from '@/lib/quote';
import { sanitizeNumberText, stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';

const VAT_PERCENT_FORMATTER = new Intl.NumberFormat('he-IL', {
  maximumFractionDigits: 2,
  minimumFractionDigits: 0
});

const quantityFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 3
});

const integerFormatter = new Intl.NumberFormat('he-IL', {
  minimumFractionDigits: 0,
  maximumFractionDigits: 0
});

export const PRIMARY_TEXT_COLOR = rgb(0.1, 0.1, 0.1);
export const SUMMARY_HIGHLIGHT_COLOR = rgb(0.02, 0.4, 0.2);

export function formatInteger(value: number): string {
  return sanitizeNumberText(integerFormatter.format(value));
}

export function formatQuantity(value: number): string {
  return sanitizeNumberText(quantityFormatter.format(value));
}

export function normalizeRtlTableValue(
  value: string | null | undefined,
  fallback = '—'
): string {
  if (value == null) {
    return stripDirectionalMarkers(fallback);
  }

  const withoutMarks = stripDirectionalMarkers(value);
  const trimmed = withoutMarks.trim();

  if (!trimmed) {
    return stripDirectionalMarkers(fallback);
  }

  return trimmed;
}

function normalizeProductName(productName: string | null | undefined): string {
  return normalizeRtlTableValue(productName);
}

function normalizeSku(sku: string | null | undefined): string {
  return normalizeRtlTableValue(sku);
}

export type QuoteTableRowInput = {
  index: number;
  qty: number;
  unitPriceCents: number;
  productName?: string | null;
  sku?: string | null;
};

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

function createTableColumns(): ReadonlyArray<ColumnDefinition> {
  const columns = TABLE_COLUMN_ORDER.map((key) =>
    Object.freeze({
      key,
      ...TABLE_COLUMN_CONFIG[key]
    })
  );
  return Object.freeze(columns) as ReadonlyArray<ColumnDefinition>;
}

export const TABLE_COLUMNS = createTableColumns();

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

export function measureTextWidth(text: string, font: PDFFont, size: number): number {
  return font.widthOfTextAtSize(stripDirectionalMarkers(text), size);
}

export function getRightAlignedX(
  text: string,
  font: PDFFont,
  size: number,
  rightEdge: number
): number {
  return rightEdge - measureTextWidth(text, font, size);
}

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

export function assertIntegerCents(value: number, field: string): void {
  if (!Number.isInteger(value)) {
    throw new Error(`Expected ${field} to be an integer number of cents`);
  }
  if (!Number.isSafeInteger(value)) {
    throw new Error(`Expected ${field} to be a safe integer number of cents`);
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
  colorRole: 'base' | 'highlight';
};

const SUMMARY_ENTRY_DEFINITIONS: readonly SummaryEntryDefinition[] = [
  {
    key: 'subtotal',
    buildLabel: () => 'סכום ביניים',
    fontSize: 12,
    colorRole: 'base'
  },
  {
    key: 'vat',
    buildLabel: (vatPercentText) => `מע"מ (${vatPercentText}%)`,
    fontSize: 12,
    colorRole: 'base'
  },
  {
    key: 'total',
    buildLabel: () => 'סה"כ לתשלום',
    fontSize: 14,
    colorRole: 'highlight'
  }
] as const satisfies ReadonlyArray<SummaryEntryDefinition>;

const SUMMARY_VALUE_FIELD_NAMES: Record<SummaryEntryKey, string> = {
  subtotal: 'summary subtotal',
  vat: 'summary VAT',
  total: 'summary total'
} as const;

function validateSummaryInputs(totals: QuoteTotals, vatRate: number): string {
  if (!Number.isFinite(vatRate)) {
    throw new Error('VAT rate must be a finite number');
  }
  if (vatRate < 0) {
    throw new Error('VAT rate must be non-negative');
  }

  assertIntegerCents(totals.subtotal, 'summary subtotal');
  assertIntegerCents(totals.vat, 'summary VAT');
  assertIntegerCents(totals.total, 'summary total');

  const expectedTotal = totals.subtotal + totals.vat;
  if (totals.total !== expectedTotal) {
    throw new Error('Summary total must equal subtotal plus VAT');
  }

  return sanitizeNumberText(VAT_PERCENT_FORMATTER.format(vatRate * 100));
}

export type SummaryEntry = {
  key: SummaryEntryKey;
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
  const vatPercentText = validateSummaryInputs(totals, vatRate);

  return SUMMARY_ENTRY_DEFINITIONS.map((definition) => ({
    key: definition.key,
    label: definition.buildLabel(vatPercentText),
    cents: totals[definition.key],
    fontSize: definition.fontSize,
    color: definition.colorRole === 'highlight' ? totalHighlightColor : baseTextColor
  }));
}

export type QuoteSummaryRow = {
  key: SummaryEntryKey;
  label: string;
  value: string;
  size: number;
};

export function prepareSummaryRows(
  totals: QuoteTotals,
  vatRate: number
): ReadonlyArray<QuoteSummaryRow> {
  const entries = buildSummaryEntries(
    totals,
    vatRate,
    PRIMARY_TEXT_COLOR,
    SUMMARY_HIGHLIGHT_COLOR
  );

  return entries.map((entry) => ({
    key: entry.key,
    label: wrapRtl(entry.label),
    value: formatCurrencyForPdf(entry.cents, SUMMARY_VALUE_FIELD_NAMES[entry.key]),
    size: entry.fontSize
  }));
}

export type SummaryTextEntry = {
  key: SummaryEntryKey;
  labelText: string;
  valueText: string;
  fontSize: number;
  valueColor: RGB;
};

export function buildSummaryTextEntries(
  totals: QuoteTotals,
  vatRate: number,
  baseTextColor: RGB = PRIMARY_TEXT_COLOR,
  totalHighlightColor: RGB = SUMMARY_HIGHLIGHT_COLOR
): SummaryTextEntry[] {
  const entries = buildSummaryEntries(totals, vatRate, baseTextColor, totalHighlightColor);

  return entries.map((entry) => ({
    key: entry.key,
    labelText: wrapRtl(entry.label),
    valueText: formatCurrencyForPdf(entry.cents, SUMMARY_VALUE_FIELD_NAMES[entry.key]),
    fontSize: entry.fontSize,
    valueColor: entry.color
  }));
}

export function buildTableRowEntries({
  index,
  qty,
  unitPriceCents,
  productName,
  sku
}: QuoteTableRowInput): Record<ColumnKey, string> {
  const lineTotalCents = computeLineTotalCents(qty, unitPriceCents);

  return {
    index: formatInteger(index + 1),
    name: normalizeProductName(productName),
    sku: normalizeSku(sku),
    qty: formatQuantity(qty),
    unit: formatCurrencyForPdf(unitPriceCents, 'unit price'),
    total: formatCurrencyForPdf(lineTotalCents, 'line total')
  };
}
