import { describe, expect, test } from 'vitest';
import { sanitizeNumberText, stripDirectionalMarkers, wrapRtl } from '@/lib/pdf/rtl';

describe('pdf RTL helpers', () => {
  test('stripDirectionalMarkers removes direction controls from mixed text', () => {
    const raw = `\u202A₪\u202C\u200F1,234.50\u2067`;
    expect(stripDirectionalMarkers(raw)).toBe('₪1,234.50');
  });

  test('sanitizeNumberText keeps digits, punctuation, and symbols', () => {
    const raw = `₪\u202B9,876\u202C.54`;
    expect(sanitizeNumberText(raw)).toBe('₪9,876.54');
  });

  test('wrapRtl wraps content with embedding marks without altering payload', () => {
    const payload = 'הצעת מחיר 42';
    const wrapped = wrapRtl(payload);
    expect(wrapped.startsWith('\u202B')).toBe(true);
    expect(wrapped.endsWith('\u202C')).toBe(true);
    expect(stripDirectionalMarkers(wrapped)).toBe(payload);
  });
});

