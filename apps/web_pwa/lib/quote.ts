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

export function computeTotals(items: ReadonlyArray<QuoteLine>, vatRate: number): QuoteTotals {
  assertFiniteNumber(vatRate, 'VAT rate must be a finite number');
  if (vatRate < 0) {
    throw new Error('VAT rate must be non-negative');
  }

  let subtotal = 0;

  for (const item of items) {
    assertFiniteNumber(item.qty, 'Item quantity must be a finite number');
    assertFiniteNumber(item.unitPriceCents, 'Item price must be a finite number');
    if (item.qty < 0) {
      throw new Error('Item quantity must be non-negative');
    }
    if (item.unitPriceCents < 0) {
      throw new Error('Item price must be non-negative');
    }
    if (!Number.isInteger(item.unitPriceCents)) {
      throw new Error('Item price must be an integer number of cents');
    }

    const lineTotal = Math.round(item.unitPriceCents * item.qty);
    subtotal += lineTotal;
  }

  const vat = Math.round(subtotal * vatRate);
  const total = subtotal + vat;

  return {
    subtotal,
    vat,
    total
  };
}
