'use client';

import { FormEvent, useEffect, useMemo, useState } from 'react';
import { isAdminReadOnly } from '@/lib/admin/access';

type CatalogVariant = {
  id: string;
  price_cents: number;
};

type CatalogProduct = {
  id: string;
  name: string;
  slug: string;
  sku: string | null;
  brand: string | null;
  category_slug: string;
  primary_image_url: string | null;
  description_html: string | null;
  is_active: boolean;
  created_at: string | null;
  default_variant: CatalogVariant | null | undefined;
};

type CatalogCategory = {
  id: string;
  name: string;
  slug: string;
};

type CatalogResponse = {
  products: CatalogProduct[];
  categories: CatalogCategory[];
  brands: string[];
  readOnly?: boolean;
};

type Filters = {
  q: string;
  brand: string;
  category: string;
};

type FormState = {
  id?: string;
  name: string;
  slug: string;
  sku: string;
  brand: string;
  category_slug: string;
  price_cents: string;
  primary_image_url: string;
  description_html: string;
  is_active: boolean;
  created_at?: string | null;
};

const EMPTY_FORM: FormState = {
  name: '',
  slug: '',
  sku: '',
  brand: '',
  category_slug: '',
  price_cents: '0',
  primary_image_url: '',
  description_html: '',
  is_active: true
};

const READ_ONLY_STORAGE_KEY = 'admin.catalog.readonly';
const EXPORT_LINKS: { key: 'products' | 'variants' | 'categories'; label: string }[] = [
  { key: 'products', label: 'products.json' },
  { key: 'variants', label: 'variants.json' },
  { key: 'categories', label: 'categories.json' }
];
const FORCED_READ_ONLY = isAdminReadOnly();

function formatPrice(cents: number | null | undefined): string {
  if (!cents && cents !== 0) {
    return '—';
  }
  return `${(cents / 100).toFixed(2)} ₪`;
}

export default function AdminCatalogPage() {
  const [filters, setFilters] = useState<Filters>({ q: '', brand: '', category: '' });
  const [products, setProducts] = useState<CatalogProduct[]>([]);
  const [categories, setCategories] = useState<CatalogCategory[]>([]);
  const [brands, setBrands] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [formState, setFormState] = useState<FormState>(EMPTY_FORM);
  const [status, setStatus] = useState<string | null>(null);
  const [selectedSlug, setSelectedSlug] = useState<string | null>(null);
  const [readOnly, setReadOnly] = useState<boolean>(FORCED_READ_ONLY);
  const [serverLocked, setServerLocked] = useState<boolean>(FORCED_READ_ONLY);
  const [backupLoading, setBackupLoading] = useState(false);

  const readOnlyActive = serverLocked || readOnly;

  useEffect(() => {
    if (typeof window === 'undefined') {
      return;
    }
    if (FORCED_READ_ONLY) {
      window.localStorage.setItem(READ_ONLY_STORAGE_KEY, '1');
      setReadOnly(true);
      setServerLocked(true);
      return;
    }
    const stored = window.localStorage.getItem(READ_ONLY_STORAGE_KEY);
    if (stored) {
      setReadOnly(stored === '1');
    }
  }, []);

  const selectedProduct = useMemo(
    () => (selectedSlug ? products.find((item) => item.slug === selectedSlug) ?? null : null),
    [products, selectedSlug]
  );

  useEffect(() => {
    const controller = new AbortController();
    async function load() {
      setLoading(true);
      setError(null);
      setStatus(null);
      try {
        const params = new URLSearchParams();
        if (filters.q) params.set('q', filters.q);
        if (filters.brand) params.set('brand', filters.brand);
        if (filters.category) params.set('category', filters.category);
        const response = await fetch(`/api/admin/catalog?${params.toString()}`, {
          cache: 'no-store',
          signal: controller.signal
        });
        if (!response.ok) {
          const payload = await response.json().catch(() => ({ error: 'שגיאת שרת' }));
          if (response.status === 403) {
            setError(payload.error || 'גישה נדחתה לקטלוג המנהלים.');
            setProducts([]);
            setCategories([]);
            setBrands([]);
            return;
          }
          throw new Error(payload.error || 'טעינת הקטלוג נכשלה');
        }
        const payload = (await response.json()) as CatalogResponse;
        setProducts(payload.products);
        setCategories(payload.categories);
        setBrands(payload.brands);
        if (typeof payload.readOnly === 'boolean') {
          const serverReadOnly = payload.readOnly;
          setServerLocked(serverReadOnly || FORCED_READ_ONLY);
          if (serverReadOnly || FORCED_READ_ONLY) {
            setReadOnly(true);
            if (typeof window !== 'undefined') {
              window.localStorage.setItem(READ_ONLY_STORAGE_KEY, '1');
            }
          }
        }
      } catch (err) {
        if (err instanceof DOMException && err.name === 'AbortError') return;
        setError(err instanceof Error ? err.message : 'טעינה נכשלה');
      } finally {
        setLoading(false);
      }
    }
    load();
    return () => controller.abort();
  }, [filters]);

  useEffect(() => {
    if (selectedProduct) {
      setFormState({
        id: selectedProduct.id,
        name: selectedProduct.name,
        slug: selectedProduct.slug,
        sku: selectedProduct.sku ?? '',
        brand: selectedProduct.brand ?? '',
        category_slug: selectedProduct.category_slug,
        price_cents: String(selectedProduct.default_variant?.price_cents ?? 0),
        primary_image_url: selectedProduct.primary_image_url ?? '',
        description_html: selectedProduct.description_html ?? '',
        is_active: selectedProduct.is_active,
        created_at: selectedProduct.created_at
      });
    } else {
      setFormState(EMPTY_FORM);
    }
  }, [selectedProduct]);

  const toggleReadOnly = () => {
    if (FORCED_READ_ONLY || serverLocked) {
      return;
    }
    setStatus(null);
    setError(null);
    setReadOnly((prev) => {
      const next = !prev;
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(READ_ONLY_STORAGE_KEY, next ? '1' : '0');
      }
      return next;
    });
  };

  const backupDisabled = readOnlyActive || backupLoading;

  const handleFilterChange = (key: keyof Filters) => (event: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFilters((prev) => ({ ...prev, [key]: event.target.value }));
  };

  const handleFormChange = (key: keyof FormState) => (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const value = event.target.type === 'checkbox' ? (event.target as HTMLInputElement).checked : event.target.value;
    setFormState((prev) => ({ ...prev, [key]: value }));
  };

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus(null);
    setError(null);

    if (readOnlyActive) {
      setError('מצב קריאה בלבד פעיל. לא ניתן לשמור שינויים.');
      return;
    }

    const price = Math.round(Number.parseFloat(formState.price_cents || '0'));
    if (!formState.slug) {
      setError('יש למלא slug ייחודי.');
      return;
    }
    if (!Number.isFinite(price) || price <= 0) {
      setError('מחיר חייב להיות גדול מאפס.');
      return;
    }
    try {
      const payload = {
        action: 'upsert',
        product: {
          id: formState.id,
          name: formState.name.trim(),
          slug: formState.slug.trim().toLowerCase(),
          sku: formState.sku.trim(),
          brand: formState.brand.trim(),
          category_slug: formState.category_slug.trim() || 'general',
          primary_image_url: formState.primary_image_url.trim(),
          description_html: formState.description_html.trim(),
          is_active: formState.is_active,
          price_cents: price,
          created_at: formState.created_at ?? undefined
        }
      };
      const response = await fetch('/api/admin/catalog', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!response.ok) {
        const data = await response.json().catch(() => ({ error: 'שמירת מוצר נכשלה' }));
        throw new Error(data.error || 'שמירת מוצר נכשלה');
      }
      setStatus('המוצר נשמר בהצלחה.');
      setSelectedSlug(payload.product.slug);
      setFilters((prev) => ({ ...prev }));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'שמירת מוצר נכשלה');
    }
  }

  async function handleDelete() {
    if (readOnlyActive) {
      setError('מצב קריאה בלבד פעיל. לא ניתן למחוק מוצרים.');
      return;
    }
    if (!formState.slug) return;
    if (!window.confirm('למחוק מוצר זה מהקטלוג המקומי?')) return;
    try {
      const response = await fetch(`/api/admin/catalog?slug=${encodeURIComponent(formState.slug)}`, {
        method: 'DELETE'
      });
      if (!response.ok) {
        const payload = await response.json().catch(() => ({ error: 'מחיקה נכשלה' }));
        throw new Error(payload.error || 'מחיקה נכשלה');
      }
      setStatus('המוצר נמחק מהקטלוג.');
      setSelectedSlug(null);
      setFilters((prev) => ({ ...prev }));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'מחיקה נכשלה');
    }
  }

  async function handleManualBackup() {
    if (readOnlyActive) {
      setError('מצב קריאה בלבד פעיל. לא ניתן ליצור גיבוי חדש.');
      return;
    }
    setStatus(null);
    setError(null);
    setBackupLoading(true);
    try {
      const response = await fetch('/api/admin/catalog', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'backup' })
      });
      const payload = (await response.json().catch(() => ({ error: 'יצירת גיבוי נכשלה' }))) as {
        error?: string;
        files?: string[];
      };
      if (!response.ok) {
        throw new Error(payload.error || 'יצירת גיבוי נכשלה');
      }
      const files = Array.isArray(payload.files) ? payload.files : [];
      const latest = files[0];
      setStatus(latest ? `גיבוי נשמר (${latest})` : 'גיבוי נוצר בהצלחה.');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'יצירת גיבוי נכשלה');
    } finally {
      setBackupLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-12">
      <header className="mb-8">
        <h1 className="text-3xl font-bold text-slate-800">ניהול קטלוג מקומי</h1>
        <p className="mt-2 text-sm text-slate-600">
          חפשו, עדכנו והוסיפו מוצרים ישירות לקבצי JSON המקומיים. כל פעולה יוצרת גיבוי בנתיב <code className="rounded bg-slate-100 px-1">data/backup</code> לפני כתיבה.
        </p>
      </header>

      <section className="mb-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <h2 className="text-lg font-semibold text-slate-800">כלי ניהול מהירים</h2>
            <p className="mt-1 text-sm text-slate-600">
              הורידו את קבצי ה-JSON או צרו גיבוי מיידי בתיקיית <code className="rounded bg-slate-100 px-1">data/backup</code>.
            </p>
            {readOnlyActive ? (
              <p className="mt-2 text-xs text-amber-600">
                מצב קריאה בלבד פעיל{serverLocked ? ' (מוגדר דרך ADMIN_READONLY).' : '. ניתן לכבות זמנית בעזרת המתג.'}
              </p>
            ) : null}
          </div>
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-end">
            <label className="flex items-center gap-2 text-sm text-slate-600">
              <input
                type="checkbox"
                checked={readOnlyActive}
                onChange={toggleReadOnly}
                disabled={FORCED_READ_ONLY}
                className="h-4 w-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
              />
              מצב קריאה בלבד
              {serverLocked ? <span className="text-xs text-slate-400">(נעול משרת)</span> : null}
            </label>
            <div className="flex flex-wrap justify-end gap-2">
              {EXPORT_LINKS.map((link) => (
                <a
                  key={link.key}
                  href={`/api/admin/catalog/export?file=${link.key}`}
                  download={link.label}
                  className="rounded-full border border-slate-300 px-4 py-2 text-xs font-semibold text-slate-700 transition hover:border-emerald-400 hover:text-emerald-600"
                >
                  הורד {link.label}
                </a>
              ))}
              <button
                type="button"
                onClick={handleManualBackup}
                disabled={backupDisabled}
                className={`rounded-full px-4 py-2 text-xs font-semibold text-white transition ${
                  backupDisabled ? 'cursor-not-allowed bg-slate-300' : 'bg-emerald-500 hover:bg-emerald-600'
                }`}
              >
                {backupLoading ? 'יוצר גיבוי…' : 'צור גיבוי עכשיו'}
              </button>
            </div>
          </div>
        </div>
      </section>

      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-800">סינון קטלוג</h2>
        <div className="mt-4 grid gap-4 md:grid-cols-3">
          <label className="flex flex-col gap-1 text-sm text-slate-600">
            חיפוש לפי שם / SKU / מותג
            <input
              type="text"
              value={filters.q}
              onChange={handleFilterChange('q')}
              className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
              placeholder="לדוגמה: copper"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm text-slate-600">
            מותג
            <select
              value={filters.brand}
              onChange={handleFilterChange('brand')}
              className="rounded-2xl border border-slate-200 px-3 py-2 text-sm text-slate-700 focus:border-emerald-500 focus:outline-none"
            >
              <option value="">הכול</option>
              {brands.map((brand) => (
                <option key={brand} value={brand.toLowerCase()}>
                  {brand}
                </option>
              ))}
            </select>
          </label>
          <label className="flex flex-col gap-1 text-sm text-slate-600">
            קטגוריה
            <select
              value={filters.category}
              onChange={handleFilterChange('category')}
              className="rounded-2xl border border-slate-200 px-3 py-2 text-sm text-slate-700 focus:border-emerald-500 focus:outline-none"
            >
              <option value="">הכול</option>
              {categories.map((category) => (
                <option key={category.id} value={category.slug}>
                  {category.name}
                </option>
              ))}
            </select>
          </label>
        </div>
      </section>

      <section className="mt-8 grid gap-6 lg:grid-cols-[1.4fr_1fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-slate-800">מוצרים ({products.length})</h2>
            <button
              type="button"
              className="rounded-full border border-emerald-500 px-4 py-1.5 text-sm font-semibold text-emerald-600 hover:bg-emerald-50"
              onClick={() => setSelectedSlug(null)}
            >
              מוצר חדש
            </button>
          </div>
          <div className="mt-4 max-h-[460px] overflow-y-auto">
            {loading ? (
              <p className="text-sm text-slate-500">טוען מוצרים…</p>
            ) : products.length ? (
              <ul className="space-y-3">
                {products.map((product) => (
                  <li key={product.id}>
                    <button
                      type="button"
                      onClick={() => setSelectedSlug(product.slug)}
                      className={`w-full rounded-2xl border px-4 py-3 text-right transition ${
                        selectedSlug === product.slug
                          ? 'border-emerald-500 bg-emerald-50 shadow-inner'
                          : 'border-slate-200 bg-white hover:border-emerald-300'
                      }`}
                    >
                      <div className="flex items-center justify-between text-sm text-slate-500">
                        <span className="font-mono text-xs">{product.slug}</span>
                        <span>{formatPrice(product.default_variant?.price_cents)}</span>
                      </div>
                      <div className="text-base font-semibold text-slate-800">{product.name}</div>
                      <div className="mt-1 flex flex-wrap gap-2 text-xs text-slate-500">
                        {product.brand ? <span>מותג: {product.brand}</span> : null}
                        <span>קטגוריה: {product.category_slug}</span>
                        <span>{product.is_active ? 'פעיל' : 'מושהה'}</span>
                      </div>
                    </button>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-sm text-slate-500">לא נמצאו מוצרים עבור הסינון הנוכחי.</p>
            )}
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-800">עריכת מוצר</h2>
          <form className="mt-4 space-y-4" onSubmit={handleSubmit}>
            <label className="flex flex-col gap-1 text-sm text-slate-600">
              שם מוצר
              <input
                type="text"
                value={formState.name}
                onChange={handleFormChange('name')}
                className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
              />
            </label>
            <div className="grid gap-4 sm:grid-cols-2">
              <label className="flex flex-col gap-1 text-sm text-slate-600">
                Slug
                <input
                  type="text"
                  value={formState.slug}
                  onChange={handleFormChange('slug')}
                  className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
                  required
                />
              </label>
              <label className="flex flex-col gap-1 text-sm text-slate-600">
                SKU
                <input
                  type="text"
                  value={formState.sku}
                  onChange={handleFormChange('sku')}
                  className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
                />
              </label>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              <label className="flex flex-col gap-1 text-sm text-slate-600">
                מותג
                <input
                  type="text"
                  value={formState.brand}
                  onChange={handleFormChange('brand')}
                  className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
                />
              </label>
              <label className="flex flex-col gap-1 text-sm text-slate-600">
                קטגוריה
                <input
                  type="text"
                  value={formState.category_slug}
                  onChange={handleFormChange('category_slug')}
                  className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
                  placeholder="לדוגמה: plumbing"
                />
              </label>
            </div>
            <label className="flex flex-col gap-1 text-sm text-slate-600">
              כתובת תמונה ראשית
              <input
                type="text"
                value={formState.primary_image_url}
                onChange={handleFormChange('primary_image_url')}
                className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm text-slate-600">
              מחיר (₪)
              <input
                type="number"
                min="0"
                step="0.01"
                value={(Number.parseFloat(formState.price_cents) / 100).toFixed(2)}
                onChange={(event) => {
                  const next = Math.max(0, Number.parseFloat(event.target.value || '0'));
                  setFormState((prev) => ({ ...prev, price_cents: String(Math.round(next * 100)) }));
                }}
                className="rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
              />
            </label>
            <label className="flex flex-col gap-1 text-sm text-slate-600">
              תיאור HTML
              <textarea
                value={formState.description_html}
                onChange={handleFormChange('description_html')}
                className="h-24 rounded-2xl border border-slate-200 px-3 py-2 text-sm shadow-inner focus:border-emerald-500 focus:outline-none"
              />
            </label>
            <label className="inline-flex items-center gap-2 text-sm text-slate-600">
              <input
                type="checkbox"
                checked={formState.is_active}
                onChange={handleFormChange('is_active')}
                className="h-4 w-4 rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
              />
              מוצר פעיל
            </label>
            {status ? <p className="text-sm text-emerald-600">{status}</p> : null}
            {error ? <p className="text-sm text-red-600">{error}</p> : null}
            <div className="flex flex-wrap gap-3">
              <button
                type="submit"
                disabled={readOnlyActive}
                className={`rounded-full px-5 py-2 text-sm font-semibold transition ${
                  readOnlyActive
                    ? 'cursor-not-allowed bg-slate-300 text-slate-500'
                    : 'bg-emerald-600 text-white hover:bg-emerald-700'
                }`}
              >
                שמור מוצר
              </button>
              {selectedProduct ? (
                <button
                  type="button"
                  onClick={handleDelete}
                  disabled={readOnlyActive}
                  className={`rounded-full border px-5 py-2 text-sm font-semibold transition ${
                    readOnlyActive
                      ? 'cursor-not-allowed border-slate-300 text-slate-400'
                      : 'border-red-500 text-red-600 hover:bg-red-50'
                  }`}
                >
                  מחיקת מוצר
                </button>
              ) : null}
            </div>
          </form>
        </div>
      </section>
    </div>
  );
}
