import { describe, expect, test } from 'vitest';
import { renderToStaticMarkup } from 'react-dom/server';
import NotFound from '@/app/not-found';

describe('custom not-found page', () => {
  test('renders fallback message and back link', () => {
    const html = renderToStaticMarkup(<NotFound />);
    expect(html).toContain('הדף לא נמצא');
    expect(html).toContain('חזרה לדף הבית');
  });
});
