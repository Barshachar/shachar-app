import Image from 'next/image';
import Link from 'next/link';
import type { Metadata } from 'next';
import CategoryCard from '@/components/CategoryCard';
import ProductCard from '@/components/ProductCard';
import QuickOrder from '@/components/QuickOrder';
import WhatsAppButton from '@/components/WhatsAppButton';
import { fetchCategories, fetchHeroProducts, fetchNewestProducts, fetchVendors } from '@/lib/data';
import { canonical, getBaseUrl, orgJsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  alternates: {
    canonical: canonical('/')
  }
};

export default async function HomePage() {
  const [categories, vendors, heroProducts, newestProducts] = await Promise.all([
    fetchCategories(),
    fetchVendors(),
    fetchHeroProducts(),
    fetchNewestProducts(8)
  ]);
  const baseUrl = getBaseUrl();
  const searchTarget = `${baseUrl}/search?q={search_term_string}`;
  const jsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      orgJsonLd(),
      {
        '@type': 'WebSite',
        '@id': `${baseUrl}#website`,
        url: baseUrl,
        name: 'א.שחר • אינסטלציה סיטונאית',
        potentialAction: {
          '@type': 'SearchAction',
          target: searchTarget,
          'query-input': 'required name=search_term_string'
        }
      }
    ]
  };

  return (
    <div className="bg-slate-50">
      <script type="application/ld+json" suppressHydrationWarning dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <section className="relative overflow-hidden bg-gradient-to-br from-emerald-600 via-emerald-500 to-cyan-500 py-16 text-white">
        <div className="absolute inset-y-0 left-0 hidden h-full w-1/2 bg-emerald-700/40 lg:block" aria-hidden="true" />
        <div className="relative mx-auto flex max-w-6xl flex-col gap-10 px-4 lg:flex-row lg:items-center">
          <div className="space-y-6 lg:w-1/2">
            <span className="inline-flex rounded-full bg-white/10 px-4 py-1 text-sm font-semibold uppercase tracking-widest text-white/80">
              B2B + B2C
            </span>
            <h1 className="text-4xl font-black lg:text-5xl">הקטלוג המלא לאינסטלטורים ולקוחות פרטיים</h1>
            <p className="text-lg text-emerald-50">
              פלטפורמה מולטי־וונדור עם מחירי קמעונאות גלויים, ומחירי עסקים מותאמים לאחר התחברות.
            </p>
            <div className="flex flex-wrap gap-3 text-sm">
              <span className="rounded-full bg-white/20 px-3 py-1">Cardcom סליקה מאובטחת</span>
              <span className="rounded-full bg-white/20 px-3 py-1">תמחור טיר לעסקים</span>
              <span className="rounded-full bg-white/20 px-3 py-1">תמיכה מלאה ב־RTL</span>
            </div>
          </div>
          <div className="lg:w-1/2">
            <div className="grid grid-cols-2 gap-4">
              {heroProducts.slice(0, 4).map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-12">
        <h2 className="mb-4 text-2xl font-bold text-slate-800">ספקים בולטים</h2>
        <div className="flex flex-wrap gap-4">
          {vendors.map((vendor) => (
            <div
              key={vendor.id}
              className="flex min-w-[140px] flex-col items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-white px-4 py-6 shadow-sm"
            >
              <div className="relative h-14 w-14 overflow-hidden rounded-full">
                <Image
                  src={vendor.logo_url || '/placeholders/p0.png'}
                  alt={vendor.name}
                  fill
                  sizes="56px"
                  className="object-cover"
                  loading="lazy"
                />
              </div>
              <span className="text-sm font-semibold text-slate-700">{vendor.name}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-12">
        <div className="flex items-center justify-between">
          <h2 className="text-2xl font-bold text-slate-800">קטגוריות מובילות</h2>
          <Link prefetch href="/category/plumbing" className="text-sm font-semibold text-emerald-600">
            לכל הקטלוג →
          </Link>
        </div>
        <div className="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {categories.map((category) => (
            <CategoryCard key={category.id} category={category} />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-12">
        <div className="flex items-center justify-between">
          <h2 className="text-2xl font-bold text-slate-800">מוצרים חדשים</h2>
          <span className="text-sm text-slate-500">התווספו לאחרונה לקטלוג המקומי</span>
        </div>
        <div className="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {newestProducts.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-12">
        <div className="flex items-center justify-between">
          <h2 className="text-2xl font-bold text-slate-800">מוצרים נבחרים</h2>
          <span className="text-sm text-slate-500">B2C גלוי • B2B לאחר התחברות</span>
        </div>
        <div className="mt-6 grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {heroProducts.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl rounded-3xl bg-white px-4 py-12 shadow-sm">
        <div className="grid gap-8 lg:grid-cols-[1.2fr_1fr]">
          <div>
            <h2 className="text-2xl font-bold text-slate-800">תמחור טיר לעסקים</h2>
            <p className="mt-2 text-slate-600">
              לקוחות עסקיים מקבלים הרשאות למחירי קבוצות, הצעות מחיר מרוכזות ומעקב הזמנות.
            </p>
            <ul className="mt-4 space-y-2 text-sm text-slate-600">
              <li>• קבוצות מחיר Installer / Wholesale</li>
              <li>• ניהול חשבון עסקי עם היסטוריית הזמנות</li>
              <li>• תיאום חשבוניות ותשלומים מול Cardcom</li>
            </ul>
            <div className="mt-6 rounded-3xl border border-dashed border-emerald-400 bg-emerald-50 p-6 text-sm text-emerald-700">
              <h3 className="text-lg font-semibold">כלי הזמנה מהירה לעסקים</h3>
              <p className="mt-2">
                הזינו רשימת SKU וכמויות או העלו קובץ CSV – נוסיף את המוצרים לעגלה שלכם בשניות.
              </p>
            </div>
          </div>
          <QuickOrder />
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-12">
        <div className="grid gap-10 md:grid-cols-2">
          <div className="space-y-3">
            <h2 className="text-2xl font-bold text-slate-800">צריכים הצעת מחיר מרוכזת?</h2>
            <p className="text-slate-600">
              פנו אלינו עם רשימת פריטים ואנו נבנה עבורכם סל מותאם עם תמחור B2B לפי טיר.
            </p>
            <a
              href="mailto:sales@ashachar.co.il"
              className="inline-flex items-center gap-2 text-sm font-semibold text-emerald-600"
            >
              שלחו מייל • sales@ashachar.co.il
            </a>
            <p className="text-sm text-slate-500">או חייגו ‎08-933-1441.</p>
          </div>
          <div className="rounded-3xl border border-dashed border-emerald-400 bg-emerald-50 p-6 text-emerald-700">
            <h3 className="text-xl font-semibold">מוכנים להמרת WooCommerce?</h3>
            <p className="mt-2 text-sm">
              תשתית Next.js 14 מוכנה לפריסה – מ-cache ועד SEO ותהליכי סליקה מאובטחים.
            </p>
            <ul className="mt-4 space-y-1 text-xs">
              <li>✓ הפניות SEO, sitemap ו-robots</li>
              <li>✓ עגלה לא מזוהה עם Cookie Session</li>
              <li>✓ חיבור Cardcom Redirect + Webhook</li>
            </ul>
          </div>
        </div>
      </section>

      <WhatsAppButton />
    </div>
  );
}
