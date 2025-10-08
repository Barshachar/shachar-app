'use client';

import Image from 'next/image';
import { useState } from 'react';
import { usePricingMode } from '@/app/providers';
import Price from '@/components/Price';
import QuantityInput from '@/components/QuantityInput';
import { computeCartTotal, computeDisplayPrice } from '@/lib/pricing';
import type { CartItem } from '@/lib/types';

async function callCartApi(path: string, payload?: Record<string, unknown>) {
  const response = await fetch(`/api/cart${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: payload ? JSON.stringify(payload) : undefined
  });
  if (!response.ok) {
    throw new Error('שגיאה בעדכון העגלה');
  }
  return response.json().catch(() => ({}));
}

export default function CartView({ initialItems }: { initialItems: CartItem[] }) {
  const [items, setItems] = useState<CartItem[]>(initialItems);
  const [error, setError] = useState<string | null>(null);
  const [quoteLoading, setQuoteLoading] = useState(false);
  const { mode, priceGroup } = usePricingMode();

  const updateQuantity = async (item: CartItem, qty: number) => {
    try {
      setError(null);
      if (qty === 0) {
        await callCartApi('/remove', { item_id: item.id });
        setItems((prev) => prev.filter((line) => line.id !== item.id));
      } else {
        await callCartApi('/update', { item_id: item.id, qty });
        setItems((prev) => prev.map((line) => (line.id === item.id ? { ...line, qty } : line)));
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאת עגלה');
    }
  };

  const clearCart = async () => {
    try {
      setError(null);
      await callCartApi('/clear');
      setItems([]);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שגיאת עגלה');
    }
  };

  const downloadQuote = async () => {
    if (!items.length || quoteLoading) {
      return;
    }
    try {
      setError(null);
      setQuoteLoading(true);
      const response = await fetch('/api/quote', {
        method: 'POST'
      });
      if (!response.ok) {
        const payload = await response.json().catch(() => ({ error: 'יצוא הצעת מחיר נכשל' }));
        throw new Error(payload.error || 'יצוא הצעת מחיר נכשל');
      }
      const blob = await response.blob();
      const disposition = response.headers.get('Content-Disposition') ?? '';
      const match = disposition.match(/filename="?([^";]+)"?/i);
      const fallbackName = 'quote.pdf';
      const filename = match ? decodeURIComponent(match[1]) : fallbackName;
      const link = document.createElement('a');
      const fileUrl = URL.createObjectURL(blob);
      link.href = fileUrl;
      link.download = filename || fallbackName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(fileUrl);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'יצוא הצעת מחיר נכשל');
    } finally {
      setQuoteLoading(false);
    }
  };

  const totalCents = computeCartTotal(
    items.map((item) => ({ variant: item.variant, qty: item.qty })),
    mode,
    priceGroup
  );

  return (
    <div className="space-y-6">
      {items.length === 0 ? (
        <div className="rounded-3xl border border-dashed border-emerald-300 bg-emerald-50 p-6 text-center text-emerald-700">
          העגלה ריקה. התחילו להוסיף מוצרים מהקטלוג.
        </div>
      ) : (
        <div className="space-y-4">
          {items.map((item) => {
            const priceInfo = computeDisplayPrice({ variant: item.variant, mode, priceGroup });
            return (
              <div
                key={item.id}
                className="flex flex-col gap-4 rounded-3xl bg-white p-4 shadow-sm md:flex-row md:items-center md:justify-between"
              >
                <div className="flex flex-1 items-center gap-4">
                  <Image
                    src={item.product.primary_image_url || '/placeholders/p0.png'}
                    alt={item.product.name}
                    width={80}
                    height={80}
                    className="h-20 w-20 rounded-2xl object-cover"
                  />
                  <div>
                    <div className="text-sm text-slate-500">{item.product.vendor_slug}</div>
                    <div className="text-lg font-semibold text-slate-800">{item.product.name}</div>
                    <div className="text-xs text-slate-500">מק"ט: {item.variant.sku || 'ללא'}</div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <QuantityInput value={item.qty} onChange={(qty) => updateQuantity(item, qty)} />
                  <button
                    type="button"
                    className="text-xs text-red-500 hover:text-red-600"
                    onClick={() => updateQuantity(item, 0)}
                  >
                    הסרה
                  </button>
                </div>
                <Price valueCents={priceInfo.valueCents * item.qty} note={priceInfo.isB2B ? 'מחיר טיר' : undefined} />
              </div>
            );
          })}
        </div>
      )}

      <div className="flex flex-col items-end gap-4 rounded-3xl bg-white p-6 shadow-sm">
        <Price valueCents={totalCents} highlight note={'סה"כ כולל מע"מ'} />
        <div className="flex gap-3">
          <a
            href="/checkout"
            className="inline-flex items-center justify-center rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white hover:bg-emerald-700"
          >
            המשך לתשלום
          </a>
          <button
            type="button"
            onClick={downloadQuote}
            disabled={quoteLoading || !items.length}
            className={`rounded-full border px-5 py-3 text-sm font-semibold transition ${
              quoteLoading || !items.length
                ? 'cursor-not-allowed border-slate-200 text-slate-400'
                : 'border-emerald-300 text-emerald-600 hover:border-emerald-500 hover:text-emerald-700'
            }`}
          >
            {quoteLoading ? 'יוצר PDF…' : 'ייצוא הצעת מחיר (PDF)'}
          </button>
          <button
            type="button"
            onClick={clearCart}
            className="rounded-full border border-slate-200 px-5 py-3 text-sm text-slate-600 hover:border-red-300 hover:text-red-500"
          >
            נקה עגלה
          </button>
        </div>
      </div>

      {error ? <div className="rounded-2xl border border-red-300 bg-red-50 p-3 text-sm text-red-600">{error}</div> : null}
    </div>
  );
}
