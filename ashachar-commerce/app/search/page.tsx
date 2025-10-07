import { Metadata } from 'next';
import ProductCard from '@/components/ProductCard';
import CategoryFilters from '@/components/CategoryFilters';
import { parseFilterParams } from '@/lib/filter-utils';
import { fetchCategories, searchProducts } from '@/lib/data';

export const metadata: Metadata = {
  title: 'חיפוש מוצרים',
  description: 'חיפוש, סינון ומיון קטלוג המוצרים של א.שחר.'
};

type PageProps = {
  searchParams?: Record<string, string | string[] | undefined>;
};

function extractBrands(products: Awaited<ReturnType<typeof searchProducts>>): string[] {
  const unique = new Set(
    products
      .map((product) => product.brand)
      .filter((brand): brand is string => typeof brand === 'string' && brand.length > 0)
  );
  return Array.from(unique).sort((a, b) => a.localeCompare(b));
}

function toQueryString(params?: Record<string, string | string[] | undefined>): string {
  if (!params) {
    return '';
  }
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (Array.isArray(value)) {
      value.forEach((item) => query.append(key, item));
    } else if (typeof value === 'string') {
      query.set(key, value);
    }
  }
  return query.toString();
}

export default async function SearchPage({ searchParams }: PageProps) {
  const { filters, initial } = parseFilterParams(searchParams);
  const baseFilters = filters.q ? { q: filters.q, sort: 'relevance' as const } : { sort: 'relevance' as const };

  const [filteredProducts, baseProducts, categories] = await Promise.all([
    searchProducts(filters),
    searchProducts(baseFilters),
    fetchCategories()
  ]);

  const brands = extractBrands(baseProducts);
  const queryLabel = filters.q?.trim() ? ` עבור "${filters.q}"` : '';
  const rawParams = toQueryString(searchParams);

  return (
    <div className="mx-auto max-w-6xl px-4 py-12">
      <header className="mb-8 flex flex-col gap-4 rounded-3xl bg-white p-6 shadow-sm">
        <div className="text-sm text-slate-500">חיפוש בקטלוג</div>
        <h1 className="text-3xl font-bold text-slate-800">תוצאות חיפוש{queryLabel}</h1>
        <p className="text-slate-600">סננו לפי מותג, מחיר וזמינות כדי למצוא במהירות את הציוד שאתם צריכים.</p>
        <CategoryFilters brands={brands} initialFilters={initial} actionPath="/search" currentParams={rawParams} />
      </header>

      {filteredProducts.length ? (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {filteredProducts.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      ) : (
        <div className="rounded-3xl border border-dashed border-emerald-300 bg-emerald-50 p-6 text-emerald-700">
          לא נמצאו מוצרים התואמים לחיפוש או לפילטרים שבחרתם. נסו מונח אחר או התאימו את האפשרויות.
        </div>
      )}

      <section className="mt-12 rounded-3xl bg-white p-6 shadow-sm">
        <h2 className="text-xl font-semibold text-slate-800">מבט מהיר לקטגוריות</h2>
        <p className="mt-2 text-sm text-slate-600">גלו קטגוריות מובילות ועמיקו את החיפוש לפי תחום.</p>
        <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {categories.slice(0, 6).map((category) => (
            <a
              key={category.id}
              href={`/category/${category.slug}`}
              className="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 transition hover:border-emerald-400 hover:bg-white"
            >
              {category.name}
            </a>
          ))}
        </div>
      </section>
    </div>
  );
}
