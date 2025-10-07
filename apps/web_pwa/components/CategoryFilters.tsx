'use client';

import { useRouter, usePathname } from 'next/navigation';
import { useMemo, useState, FormEvent } from 'react';
import type { ProductFilters } from '@/lib/data';
import type { InitialFilterState } from '@/lib/filter-utils';

type SortValue = NonNullable<ProductFilters['sort']>;

const sortOptions: { value: SortValue; label: string }[] = [
  { value: 'relevance', label: 'רלוונטיות' },
  { value: 'price_asc', label: 'מחיר – מהזול ליקר' },
  { value: 'price_desc', label: 'מחיר – מהיקר לזול' },
  { value: 'name_asc', label: 'שם המוצר' }
];

type CategoryFiltersProps = {
  categorySlug?: string;
  brands: string[];
  initialFilters: InitialFilterState;
  actionPath?: string;
  currentParams?: string;
};

export default function CategoryFilters({
  categorySlug,
  brands,
  initialFilters,
  actionPath,
  currentParams
}: CategoryFiltersProps) {
  const router = useRouter();
  const pathname = usePathname();

  const [query, setQuery] = useState(initialFilters.q);
  const [selectedBrands, setSelectedBrands] = useState<Set<string>>(new Set(initialFilters.brands));
  const [priceMin, setPriceMin] = useState(initialFilters.priceMin ? String(initialFilters.priceMin) : '');
  const [priceMax, setPriceMax] = useState(initialFilters.priceMax ? String(initialFilters.priceMax) : '');
  const [availability, setAvailability] = useState(initialFilters.availability);
  const [sort, setSort] = useState<SortValue>(initialFilters.sort ?? 'relevance');

  const brandOptions = useMemo(() => brands.sort((a, b) => a.localeCompare(b)), [brands]);

  const handleBrandToggle = (brand: string) => {
    setSelectedBrands((prev) => {
      const next = new Set(prev);
      if (next.has(brand)) {
        next.delete(brand);
      } else {
        next.add(brand);
      }
      return next;
    });
  };

  const baseParams = useMemo(() => new URLSearchParams(currentParams ?? ''), [currentParams]);

  const buildSearchParams = () => {
    const params = new URLSearchParams(baseParams.toString());
    params.delete('q');
    params.delete('brand');
    params.delete('min');
    params.delete('max');
    params.delete('availability');
    params.delete('sort');

    if (query.trim()) {
      params.set('q', query.trim());
    }

    Array.from(selectedBrands).forEach((brand) => {
      if (brand.trim()) {
        params.append('brand', brand.trim());
      }
    });

    if (priceMin.trim()) {
      params.set('min', priceMin.trim());
    }
    if (priceMax.trim()) {
      params.set('max', priceMax.trim());
    }

    if (availability === 'true' || availability === 'false') {
      params.set('availability', availability);
    }

    if (sort && sort !== 'relevance') {
      params.set('sort', sort);
    }

    return params;
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const params = buildSearchParams();
    const targetPath = actionPath ?? pathname;
    const nextPath = params.toString() ? `${targetPath}?${params.toString()}` : targetPath;
    router.push(nextPath as any);
  };

  const handleReset = () => {
    setQuery('');
    setSelectedBrands(new Set());
    setPriceMin('');
    setPriceMax('');
    setAvailability('all');
    setSort('relevance');
    const targetPath = actionPath ?? (categorySlug ? `/category/${categorySlug}` : pathname);
    router.push(targetPath as any);
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-slate-700">
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <label className="flex flex-col gap-1 text-sm">
          חיפוש
          <input
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="שם, SKU או מותג"
            className="rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-500 focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1 text-sm">
          מחיר מינימלי (₪)
          <input
            type="number"
            min={0}
            value={priceMin}
            onChange={(event) => setPriceMin(event.target.value)}
            className="rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-500 focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1 text-sm">
          מחיר מקסימלי (₪)
          <input
            type="number"
            min={0}
            value={priceMax}
            onChange={(event) => setPriceMax(event.target.value)}
            className="rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-500 focus:outline-none"
          />
        </label>
        <label className="flex flex-col gap-1 text-sm">
          סידור
          <select
            value={sort}
            onChange={(event) => setSort(event.target.value as SortValue)}
            className="rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-500 focus:outline-none"
          >
            {sortOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
      </div>
      <div className="grid gap-4 lg:grid-cols-[2fr_1fr]">
        <div>
          <span className="mb-2 block text-sm font-semibold">מותגים</span>
          <div className="grid gap-2 sm:grid-cols-2 md:grid-cols-3">
            {brandOptions.length ? (
              brandOptions.map((brand) => {
                const checked = selectedBrands.has(brand);
                return (
                  <label
                    key={brand}
                    className="flex items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-2 text-sm shadow-sm"
                  >
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={() => handleBrandToggle(brand)}
                      className="accent-emerald-600"
                    />
                    <span>{brand}</span>
                  </label>
                );
              })
            ) : (
              <p className="text-sm text-slate-500">אין מותגים ייחודיים להצגה.</p>
            )}
          </div>
        </div>
        <div className="flex flex-col gap-3">
          <label className="flex flex-col gap-1 text-sm">
            זמינות
            <select
              value={availability}
              onChange={(event) => setAvailability(event.target.value as 'all' | 'true' | 'false')}
              className="rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-emerald-500 focus:outline-none"
            >
              <option value="all">הצג הכל</option>
              <option value="true">במלאי בלבד</option>
              <option value="false">מוצרים שאזלו</option>
            </select>
          </label>
          <div className="mt-auto flex gap-3">
            <button
              type="submit"
              className="flex-1 rounded-full bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-700"
            >
              החלת פילטרים
            </button>
            <button
              type="button"
              onClick={handleReset}
              className="rounded-full border border-slate-300 px-4 py-2 text-sm text-slate-600 hover:border-slate-400 hover:text-slate-900"
            >
              איפוס
            </button>
          </div>
        </div>
      </div>
    </form>
  );
}
