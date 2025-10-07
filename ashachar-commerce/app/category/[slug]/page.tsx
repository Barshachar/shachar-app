import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import CategoryCard from '@/components/CategoryCard';
import ProductCard from '@/components/ProductCard';
import CategoryFilters from '@/components/CategoryFilters';
import { fetchCategories, fetchCategoryWithProducts } from '@/lib/data';
import { parseFilterParams } from '@/lib/filter-utils';
import { breadcrumbJsonLd, canonical } from '@/lib/seo';

export async function generateStaticParams() {
  const categories = await fetchCategories();
  return categories.map((category) => ({ slug: category.slug }));
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

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const { category } = await fetchCategoryWithProducts(params.slug);
  if (!category) {
    return {
      title: 'קטגוריה לא נמצאה'
    };
  }
  return {
    title: `${category.name} • קטלוג מוצרים`,
    description: `מבחר מוצרים בקטגוריית ${category.name} עם מחירי B2C גלויים ומחירי B2B לאחר התחברות.`,
    alternates: {
      canonical: canonical(`/category/${params.slug}`)
    }
  };
}

type PageProps = {
  params: { slug: string };
  searchParams?: Record<string, string | string[] | undefined>;
};

export default async function CategoryPage({ params, searchParams }: PageProps) {
  const { filters, initial } = parseFilterParams(searchParams);
  const { category, products, brands } = await fetchCategoryWithProducts(params.slug, filters);
  const otherCategories = (await fetchCategories()).filter((item) => item.slug !== params.slug);
  const rawParams = toQueryString(searchParams);

  if (!category) {
    notFound();
  }

  const breadcrumb = breadcrumbJsonLd([
    { name: 'בית', url: canonical('/') },
    { name: 'קטגוריות', url: canonical('/category') },
    { name: category.name, url: canonical(`/category/${category.slug}`) }
  ]);

  return (
    <div className="mx-auto max-w-6xl px-4 py-12">
      <script type="application/ld+json" suppressHydrationWarning dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumb) }} />
      <header className="mb-8 flex flex-col gap-4 rounded-3xl bg-white p-6 shadow-sm">
        <div className="text-sm text-slate-500">קטגוריה / {category.name}</div>
        <h1 className="text-3xl font-bold text-slate-800">{category.name}</h1>
        <p className="text-slate-600">
          מחירים ללקוחות פרטיים גלויים. לקוחות עסקיים – התחברו כדי לראות מחירי טיר מותאמים.
        </p>
        <CategoryFilters
          categorySlug={params.slug}
          brands={brands}
          initialFilters={initial}
          actionPath={`/category/${params.slug}`}
          currentParams={rawParams}
        />
      </header>

      {products.length > 0 ? (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      ) : (
        <div className="rounded-3xl border border-dashed border-emerald-300 bg-emerald-50 p-6 text-emerald-700">
          לא נמצאו מוצרים התואמים לחיפוש או לפילטרים שבחרתם. נסו להסיר חלק מהפילטרים או להרחיב את החיפוש.
        </div>
      )}

      <section className="mt-12">
        <h2 className="mb-4 text-xl font-semibold text-slate-800">עוד קטגוריות שיעניינו אתכם</h2>
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {otherCategories.map((item) => (
            <CategoryCard key={item.id} category={item} />
          ))}
        </div>
      </section>
    </div>
  );
}
