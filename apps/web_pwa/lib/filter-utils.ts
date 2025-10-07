import type { ProductFilters } from '@/lib/data';

export type InitialFilterState = {
  q: string;
  brands: string[];
  priceMin?: number;
  priceMax?: number;
  availability: 'all' | 'true' | 'false';
  sort: NonNullable<ProductFilters['sort']>;
};

type SearchParams = Record<string, string | string[] | undefined> | undefined;

function toArray(value: string | string[] | undefined): string[] {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

function normalizeNumber(value?: string): number | undefined {
  if (value === undefined || value === '') return undefined;
  const parsed = Number(value);
  return Number.isNaN(parsed) ? undefined : parsed;
}

const allowedSort: NonNullable<ProductFilters['sort']>[] = ['relevance', 'price_asc', 'price_desc', 'name_asc'];

export function parseFilterParams(searchParams: SearchParams): {
  filters: ProductFilters;
  initial: InitialFilterState;
} {
  const params = searchParams ?? {};
  const qRaw = typeof params.q === 'string' ? params.q.trim() : '';
  const brandValues = toArray(params.brand).map((brand) => brand.trim()).filter(Boolean);
  const priceMin = normalizeNumber(typeof params.min === 'string' ? params.min : undefined);
  const priceMax = normalizeNumber(typeof params.max === 'string' ? params.max : undefined);
  const availabilityParam = typeof params.availability === 'string' ? params.availability : 'all';
  const availability = availabilityParam === 'true' ? true : availabilityParam === 'false' ? false : null;
  const sortParam = typeof params.sort === 'string' ? params.sort : 'relevance';
  const sort = allowedSort.includes(sortParam as NonNullable<ProductFilters['sort']>)
    ? (sortParam as NonNullable<ProductFilters['sort']>)
    : 'relevance';

  const filters: ProductFilters = {
    q: qRaw || undefined,
    brands: brandValues.length ? brandValues : undefined,
    priceMin,
    priceMax,
    isActive: availability,
    sort
  };

  const initial: InitialFilterState = {
    q: qRaw,
    brands: brandValues,
    priceMin,
    priceMax,
    availability: availabilityParam === 'true' || availabilityParam === 'false' ? availabilityParam : 'all',
    sort
  };

  return { filters, initial };
}
