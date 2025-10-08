'use client';

import { useState, useEffect, FormEvent } from 'react';

type QuickOrderResult = {
  sku: string;
  qty: number;
  status: 'success' | 'error';
  message: string;
};

type SkuMapEntry = {
  sku: string;
  variant_id: string;
  name: string;
};

async function readFile(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result));
    reader.onerror = () => reject(reader.error);
    reader.readAsText(file);
  });
}

function parseLines(value: string): { sku: string; qty: number }[] {
  return value
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const parts = line.split(/[;,\s]+/).filter(Boolean);
      if (parts.length < 2) {
        return null;
      }
      const qty = Number(parts[1]);
      if (Number.isNaN(qty) || qty <= 0) {
        return null;
      }
      return { sku: parts[0], qty };
    })
    .filter((item): item is { sku: string; qty: number } => Boolean(item));
}

export default function QuickOrder() {
  const [input, setInput] = useState('');
  const [results, setResults] = useState<QuickOrderResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [skuMap, setSkuMap] = useState<Record<string, SkuMapEntry>>({});
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    fetch('/api/catalog/sku-map')
      .then((response) => response.json())
      .then((data: { items: SkuMapEntry[] }) => {
        if (!isMounted) return;
        const map: Record<string, SkuMapEntry> = {};
        data.items.forEach((item) => {
          map[item.sku.toLowerCase()] = item;
        });
        setSkuMap(map);
      })
      .catch(() => {
        if (isMounted) {
          setError('לא ניתן לטעון מפת SKU. נסו לרענן את הדף.');
        }
      });
    return () => {
      isMounted = false;
    };
  }, []);

  const handleFile = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const content = await readFile(file);
    setInput((prev) => [prev, content].filter(Boolean).join('\n'));
  };

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setResults([]);
    setError(null);
    const entries = parseLines(input);

    if (!entries.length) {
      setError('לא נמצאו שורות תקינות. ודאו פורמט SKU,כמות.');
      return;
    }

    setLoading(true);
    const batchResults: QuickOrderResult[] = [];

    for (const entry of entries) {
      const mapEntry = skuMap[entry.sku.toLowerCase()];
      if (!mapEntry) {
        batchResults.push({ sku: entry.sku, qty: entry.qty, status: 'error', message: 'SKU לא נמצא בקטלוג' });
        continue;
      }
      try {
        const response = await fetch('/api/cart/add', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({ variant_id: mapEntry.variant_id, qty: entry.qty })
        });
        if (!response.ok) {
          const payload = await response.json().catch(() => ({}));
          batchResults.push({ sku: entry.sku, qty: entry.qty, status: 'error', message: payload.error || 'שגיאת שרת' });
          continue;
        }
        batchResults.push({ sku: entry.sku, qty: entry.qty, status: 'success', message: mapEntry.name });
      } catch (err) {
        batchResults.push({ sku: entry.sku, qty: entry.qty, status: 'error', message: 'שגיאת רשת' });
      }
    }

    setResults(batchResults);
    setLoading(false);
  };

  return (
    <div className="rounded-3xl border border-dashed border-emerald-300 bg-white p-6 shadow-sm">
      <h3 className="text-xl font-semibold text-slate-800">הזמנת B2B מהירה לפי SKU</h3>
      <p className="mt-2 text-sm text-slate-600">
        הדביקו רשימת פריטים בתבנית <code className="rounded bg-slate-100 px-1">SKU,כמות</code> בכל שורה או העלו קובץ CSV. אנחנו נוסיף את הפריטים לעגלת הקניות שלכם.
      </p>
      <form onSubmit={handleSubmit} className="mt-4 space-y-4">
        <textarea
          value={input}
          onChange={(event) => setInput(event.target.value)}
          placeholder={['FC-PO-PR,2', 'WP-BP-1HP,1', 'TT-PW-018,5'].join('\n')}
          className="h-32 w-full rounded-2xl border border-slate-200 px-4 py-3 text-sm text-slate-700 shadow-inner focus:border-emerald-500 focus:outline-none"
        />
        <div className="flex flex-wrap items-center gap-3 text-sm">
          <label className="inline-flex cursor-pointer items-center gap-2 rounded-full border border-slate-300 px-3 py-2 text-slate-600 hover:border-emerald-400">
            <input type="file" accept=".csv,text/csv" className="hidden" onChange={handleFile} />
            העלאת CSV
          </label>
          <button
            type="submit"
            disabled={loading}
            className="rounded-full bg-emerald-600 px-5 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-emerald-700 disabled:opacity-60"
          >
            {loading ? 'מוסיף לעגלה…' : 'הוסף לעגלה'}
          </button>
          <span className="text-xs text-slate-500">סה"כ פריטים: {results.length ? results.filter((item) => item.status === 'success').length : 0}</span>
        </div>
      </form>
      {error ? <p className="mt-3 text-sm text-red-500">{error}</p> : null}
      {results.length ? (
        <div className="mt-6 overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-3 py-2 text-right font-semibold text-slate-600">SKU</th>
                <th className="px-3 py-2 text-right font-semibold text-slate-600">כמות</th>
                <th className="px-3 py-2 text-right font-semibold text-slate-600">סטטוס</th>
                <th className="px-3 py-2 text-right font-semibold text-slate-600">הודעה</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {results.map((result) => (
                <tr key={`${result.sku}-${result.message}`} className="bg-white">
                  <td className="px-3 py-2 font-mono">{result.sku}</td>
                  <td className="px-3 py-2 text-slate-700">{result.qty}</td>
                  <td className="px-3 py-2">
                    <span
                      className={
                        result.status === 'success'
                          ? 'inline-flex rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-semibold text-emerald-700'
                          : 'inline-flex rounded-full bg-red-100 px-2 py-0.5 text-xs font-semibold text-red-700'
                      }
                    >
                      {result.status === 'success' ? 'נוסף' : 'שגיאה'}
                    </span>
                  </td>
                  <td className="px-3 py-2 text-slate-600">{result.message}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : null}
    </div>
  );
}
