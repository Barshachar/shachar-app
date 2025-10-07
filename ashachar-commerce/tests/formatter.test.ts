import { formatILS } from '@/lib/formatter';

describe('formatILS', () => {
  it('formats shekel currency with symbol prefix', () => {
    expect(formatILS(12345)).toBe('₪ 123.45');
  });

  it('handles zero values consistently', () => {
    expect(formatILS(0)).toBe('₪ 0.00');
  });

  it('adds thousand separators for large values', () => {
    expect(formatILS(98765432)).toBe('₪ 987,654.32');
  });
});
