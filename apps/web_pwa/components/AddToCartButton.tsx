'use client';

import { useState } from 'react';

export default function AddToCartButton({
  variantId,
  onAdded
}: {
  variantId: string;
  onAdded?: () => void;
}) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleAdd = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch('/api/cart/add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ variant_id: variantId, qty: 1 })
      });
      if (!response.ok) {
        throw new Error('הוספה לעגלה נכשלה');
      }
      if (onAdded) {
        onAdded();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'אירעה שגיאה');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col gap-2">
      <button
        type="button"
        disabled={loading}
        onClick={handleAdd}
        className="inline-flex items-center justify-center gap-2 rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700 disabled:opacity-60"
      >
        {loading ? 'מוסיף...' : 'הוספה לעגלה'}
      </button>
      {error ? <span className="text-xs text-red-500">{error}</span> : null}
    </div>
  );
}
