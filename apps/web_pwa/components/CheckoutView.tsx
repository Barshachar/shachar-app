'use client';

import { useState } from 'react';
import Price from '@/components/Price';
import { usePricingMode } from '@/app/providers';
import { computeCartTotal } from '@/lib/pricing';
import type { CartItem } from '@/lib/types';

export default function CheckoutView({ initialItems }: { initialItems: CartItem[] }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { mode, priceGroup } = usePricingMode();

  if (initialItems.length === 0) {
    return (
      <div className="rounded-3xl border border-dashed border-emerald-300 bg-emerald-50 p-6 text-center text-emerald-700">
        העגלה ריקה. חזרו לקטלוג והוסיפו מוצרים לפני מעבר לתשלום.
      </div>
    );
  }

  const totalCents = computeCartTotal(
    initialItems.map((item) => ({ variant: item.variant, qty: item.qty })),
    mode,
    priceGroup
  );

  const submitCheckout = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch('/api/checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      });
      if (!response.ok) {
        throw new Error('שגיאה בהכנת תשלום');
      }
      const payload = await response.json();
      if (!payload.redirect) {
        throw new Error('כתובת Redirect חסרה');
      }
      window.location.href = payload.redirect as string;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'כשל לא ידוע');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-800">סיכום הזמנה</h2>
        <div className="mt-4 space-y-3 text-sm text-slate-600">
          {initialItems.map((item) => (
            <div key={item.id} className="flex items-center justify-between">
              <span>
                {item.product.name} × {item.qty}
              </span>
              <span>{item.variant.sku || '-'}</span>
            </div>
          ))}
        </div>
        <div className="mt-6 flex items-center justify-between rounded-2xl bg-emerald-50 p-4">
          <span className="text-sm text-emerald-700">סה"כ לתשלום</span>
          <Price valueCents={totalCents} highlight />
        </div>
        <button
          type="button"
          onClick={submitCheckout}
          disabled={loading}
          className="mt-6 w-full rounded-full bg-emerald-600 py-3 text-sm font-semibold text-white hover:bg-emerald-700 disabled:opacity-60"
        >
          {loading ? 'מנתב ל-Cardcom...' : 'המשך לתשלום (Cardcom)'}
        </button>
        {error ? <div className="mt-3 rounded-2xl border border-red-300 bg-red-50 p-3 text-sm text-red-600">{error}</div> : null}
      </div>
      <div className="rounded-3xl border border-dashed border-slate-300 bg-white/70 p-6 text-sm text-slate-600">
        תשלום מאובטח דרך Cardcom Redirect. לאחר התשלום תחזרו לעמוד אישור. קבלה/חשבונית תישלח לאחר התאמת סליקה.
      </div>
    </div>
  );
}
