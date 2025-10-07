'use client';

import Image from 'next/image';
import Link from 'next/link';
import { usePricingMode } from '@/app/providers';
import Price from '@/components/Price';
import VendorBadge from '@/components/VendorBadge';
import { computeDisplayPrice } from '@/lib/pricing';
import type { Product } from '@/lib/types';

export default function ProductCard({ product }: { product: Product }) {
  const { mode, priceGroup } = usePricingMode();
  const primaryVariant = product.variants[0];
  const display = computeDisplayPrice({ variant: primaryVariant, mode, priceGroup });

  return (
    <Link
      prefetch
      href={`/product/${product.slug}`}
      className="group flex h-full flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
    >
      <div className="relative h-48 w-full">
        <Image
          src={product.primary_image_url || '/placeholders/p0.png'}
          alt={product.name}
          fill
          className="object-cover transition-transform group-hover:scale-105"
          sizes="(max-width: 768px) 100vw, 25vw"
          loading="lazy"
        />
      </div>
      <div className="flex flex-1 flex-col gap-3 px-4 py-4">
        <div className="flex items-center justify-between gap-2">
          <div className="flex flex-col gap-1">
            {product.brand ? (
              <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-[11px] font-semibold text-emerald-700">
                {product.brand}
              </span>
            ) : null}
            <VendorBadge
              vendor={{
                name: product.brand || product.vendor_slug,
                logo_url: `/brands/${product.vendor_slug}.png`
              }}
              size="small"
            />
          </div>
          <span className="rounded-full bg-cyan-100 px-2 py-0.5 text-[10px] font-semibold text-cyan-700">
            {mode === 'b2b' ? 'B2B' : 'B2C'}
          </span>
        </div>
        <div className="flex-1">
          <h3 className="text-base font-semibold text-slate-800">{product.name}</h3>
          {product.sku ? <p className="text-xs text-slate-500">SKU: {product.sku}</p> : null}
        </div>
        <Price valueCents={display.valueCents} note={display.isB2B ? 'מחיר עסקים' : 'מחיר לצרכן'} />
      </div>
    </Link>
  );
}
