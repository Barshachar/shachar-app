'use client';

import { useState } from 'react';

type ImportResponse = {
  ok: boolean;
  processed: number;
  summary: {
    categories: { added: number; updated: number; skipped: number };
    products: { added: number; updated: number; skipped: number };
    variants: { added: number; updated: number; skipped: number };
  };
  counts: {
    categories: number;
    products: number;
    variants: number;
  };
};

export default function AdminImportPage() {
  const [message, setMessage] = useState<string | null>(null);
  const [details, setDetails] = useState<ImportResponse | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMessage(null);
    setDetails(null);

    const formData = new FormData(event.currentTarget);
    const file = formData.get('file');
    if (!(file instanceof File) || !file.size) {
      setMessage('בחרו קובץ CSV לפני השליחה.');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/admin/import', {
        method: 'POST',
        body: formData
      });
      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload.error || 'הייבוא נכשל');
      }
      setDetails(payload as ImportResponse);
      setMessage(`הייבוא הושלם – נוספו ${payload.summary.products.added} מוצרים והעודכנו ${payload.summary.products.updated}.`);
      event.currentTarget.reset();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'הייבוא נכשל');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-800">ייבוא CSV לקטלוג המקומי</h1>
      <p className="mt-2 text-sm text-slate-600">
        העלו קובץ CSV במבנה <code className="rounded bg-slate-100 px-1">name,slug,sku,brand,category_slug,price_cents,primary_image_url,description_html</code> והמערכת תבצע עדכון לקטלוג המקומי (data/*.json).
      </p>
      <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-4 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          קובץ CSV
          <input type="file" name="file" accept=".csv" className="rounded border border-slate-300 px-3 py-2" />
        </label>
        <button
          type="submit"
          disabled={loading}
          className="rounded-full bg-emerald-600 px-5 py-2 text-sm font-semibold text-white transition hover:bg-emerald-700 disabled:opacity-60"
        >
          {loading ? 'מייבא…' : 'ייבוא קובץ'}
        </button>
      </form>
      {message ? <p className="mt-4 text-sm text-slate-700">{message}</p> : null}
      {details ? (
        <div className="mt-6 rounded-3xl border border-slate-200 bg-slate-50 p-6 text-sm text-slate-700">
          <h2 className="text-lg font-semibold text-slate-800">סיכום ייבוא</h2>
          <p className="mt-2">סה"כ רשומות ב-CSV: {details.processed}</p>
          <ul className="mt-3 space-y-1">
            <li>
              קטגוריות – נוספו {details.summary.categories.added}, עודכנו {details.summary.categories.updated}
            </li>
            <li>
              מוצרים – נוספו {details.summary.products.added}, עודכנו {details.summary.products.updated}
            </li>
            <li>
              וריאנטים – נוספו {details.summary.variants.added}, עודכנו {details.summary.variants.updated}
            </li>
          </ul>
          <p className="mt-3 text-xs text-slate-500">
            לאחר הייבוא הקטלוג המקומי כולל {details.counts.products} מוצרים ו-{details.counts.categories} קטגוריות.
          </p>
        </div>
      ) : null}
    </div>
  );
}
