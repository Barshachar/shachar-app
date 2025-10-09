export type QuoteLine = {
  qty: number;
  unitPriceCents: number;
};

export type QuoteTotals = {
  subtotal: number;
  vat: number;
  total: number;
};

function assertFiniteNumber(value: number, message: string): asserts value is number {
  if (!Number.isFinite(value)) {
    throw new Error(message);
  }
}

function assertSafeIntegerCents(value: number, message: string): asserts value is number {
  if (!Number.isInteger(value)) {
    throw new Error(`${message} must be an integer number of cents`);
  }
  if (!Number.isSafeInteger(value)) {
    throw new Error(`${message} must be a safe integer number of cents`);
  }
}

export function computeLineTotalCents(qty: number, unitPriceCents: number): number {
  assertFiniteNumber(qty, 'Item quantity must be a finite number');
  assertFiniteNumber(unitPriceCents, 'Item price must be a finite number');

  if (qty < 0) {
    throw new Error('Item quantity must be non-negative');
  }
  if (unitPriceCents < 0) {
    throw new Error('Item price must be non-negative');
  }
  assertSafeIntegerCents(unitPriceCents, 'Item price');

  const lineTotalRaw = unitPriceCents * qty;
  assertFiniteNumber(lineTotalRaw, 'Line total must be a finite number');
  const lineTotal = Math.round(lineTotalRaw);
  assertSafeIntegerCents(lineTotal, 'Line total');

  return lineTotal;
}

export function computeTotals(items: ReadonlyArray<QuoteLine>, vatRate: number): QuoteTotals {
  assertFiniteNumber(vatRate, 'VAT rate must be a finite number');
  if (vatRate < 0) {
    throw new Error('VAT rate must be non-negative');
  }

  let subtotal = 0;

  for (const item of items) {
    const lineTotal = computeLineTotalCents(item.qty, item.unitPriceCents);
    subtotal += lineTotal;
    assertSafeIntegerCents(subtotal, 'Subtotal');
  }

  assertSafeIntegerCents(subtotal, 'Subtotal');

  const vatRaw = subtotal * vatRate;
  assertFiniteNumber(vatRaw, 'VAT amount must be a finite number');
  const vat = Math.round(vatRaw);
  assertSafeIntegerCents(vat, 'VAT amount');

  const total = subtotal + vat;
  assertSafeIntegerCents(total, 'Total amount');

  return {
    subtotal,
    vat,
    total
  };
}
