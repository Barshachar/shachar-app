import Image from 'next/image';
import Link from 'next/link';
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import AddToCartButton from '@/components/AddToCartButton';
import ProductPricingDetails from '@/components/ProductPricingDetails';
import VendorBadge from '@/components/VendorBadge';
import { fetchCategoryWithProducts, fetchProductBySlug } from '@/lib/data';
import { breadcrumbJsonLd, canonical, productJsonLd } from '@/lib/seo';

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const product = await fetchProductBySlug(params.slug);
  if (!product) {
    return { title: 'מוצר לא נמצא' };
  }
  return {
    title: `${product.name} | א.שחר`,
    description: product.description_html
      ? product.description_html.replace(/<[^>]+>/g, '').slice(0, 120)
      : `רכשו ${product.name} עם זמינות B2B וביצוע הזמנה מקוון.`,
    alternates: {
      canonical: canonical(`/product/${params.slug}`)
    }
  };
}

export default async function ProductPage({ params }: { params: { slug: string } }) {
  const product = await fetchProductBySlug(params.slug);
  if (!product) {
    notFound();
  }
  const categoryInfo = await fetchCategoryWithProducts(product.category_slug);
  const categoryName = categoryInfo.category?.name ?? product.category_slug;
  const primaryVariant = product.variants[0] ?? null;
  const imageUrl = (() => {
    if (product.primary_image_url && product.primary_image_url.startsWith('http')) {
      return product.primary_image_url;
    }
    return canonical(product.primary_image_url || '/placeholders/p0.png');
  })();
  const brandLabel = product.brand || product.vendor_slug;
  const breadcrumb = breadcrumbJsonLd([
    { name: 'בית', url: canonical('/') },
    { name: 'קטגוריות', url: canonical('/category') },
    { name: categoryName, url: canonical(`/category/${product.category_slug}`) },
    { name: product.name, url: canonical(`/product/${product.slug}`) }
  ]);
  const productLd = primaryVariant
    ? productJsonLd(product, {
        priceCents: primaryVariant.price_cents,
        image: imageUrl,
        brandLabel
      })
    : null;

  return (
    <div className="mx-auto max-w-5xl px-4 py-12">
      <script type="application/ld+json" suppressHydrationWarning dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumb) }} />
      {productLd ? (
        <script type="application/ld+json" suppressHydrationWarning dangerouslySetInnerHTML={{ __html: JSON.stringify(productLd) }} />
      ) : null}
      <nav className="text-xs text-slate-500">
        <Link prefetch href="/">בית</Link> /{' '}
        <Link prefetch href={`/category/${product.category_slug}`}>קטגוריה</Link> / {product.name}
      </nav>
      <div className="mt-6 grid gap-10 md:grid-cols-2">
        <div className="rounded-3xl bg-white p-4 shadow-sm">
          <div className="relative aspect-square w-full">
            <Image
              src={product.primary_image_url || '/placeholders/p0.png'}
              alt={product.name}
              fill
              className="rounded-2xl object-cover"
              sizes="(max-width: 768px) 100vw, 50vw"
              priority
            />
          </div>
        </div>
        <div className="space-y-5">
          <VendorBadge vendor={{ name: product.brand || product.vendor_slug, logo_url: `/brands/${product.vendor_slug}.png` }} />
          <h1 className="text-3xl font-bold text-slate-800">{product.name}</h1>
          {product.sku ? <p className="text-sm text-slate-500">SKU: {product.sku}</p> : null}

          {primaryVariant ? <ProductPricingDetails variant={primaryVariant} /> : null}

          {primaryVariant ? (
            <AddToCartButton variantId={primaryVariant.id} />
          ) : (
            <p className="rounded-3xl border border-dashed border-slate-200 bg-slate-50 p-4 text-sm text-slate-600">
              המוצר חסר וריאנט פעיל במצב המקומי. עדכנו את הקטלוג דרך ממשק הניהול.
            </p>
          )}

          {product.description_html ? (
            <article
              className="prose prose-slate max-w-none rtl:text-right"
              dangerouslySetInnerHTML={{ __html: product.description_html }}
            />
          ) : (
            <p className="text-sm text-slate-600">תיאור מפורט יתעדכן בקרוב בהתאם לנתונים המקומיים.</p>
          )}
        </div>
      </div>
    </div>
  );
}
