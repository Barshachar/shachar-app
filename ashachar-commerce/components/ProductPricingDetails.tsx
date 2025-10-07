'use client';

import { usePricingMode } from '@/app/providers';
import Price from '@/components/Price';
import { computeDisplayPrice } from '@/lib/pricing';
import type { ProductVariant } from '@/lib/types';

export default function ProductPricingDetails({ variant }: { variant: ProductVariant }) {
  const { mode, priceGroup } = usePricingMode();
  const display = computeDisplayPrice({ variant, mode, priceGroup });

  return (
    <div className="rounded-3xl bg-emerald-50 p-4">
      <Price
        valueCents={display.valueCents}
        highlight
        note={mode === 'b2b' ? 'מחיר לעסקים' : 'מחיר כולל מע"מ'}
      />
      {mode === 'b2b' ? (
        <p className="mt-2 text-xs text-emerald-700">
          טיר {priceGroup || 'installer'} (ברירת מחדל). הסכמים מותאמים זמינים בהתחברות.
        </p>
      ) : (
        <p className="mt-2 text-xs text-emerald-700">מחיר לצרכן כולל מע"מ.</p>
      )}
    </div>
  );
}
