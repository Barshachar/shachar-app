export function formatILS(valueCents: number): string {
  const value = valueCents / 100;
  const formatted = new Intl.NumberFormat('he-IL', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
    .format(value)
    .replace(/\u200e/g, '');

  return `₪ ${formatted}`;
}
