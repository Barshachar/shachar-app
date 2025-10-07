import Image from 'next/image';
import { fetchVendors } from '@/lib/data';

export default async function VendorsPage() {
  const vendors = await fetchVendors();
  return (
    <div className="mx-auto max-w-5xl px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-800">ספקים ושותפים</h1>
      <p className="mt-2 text-sm text-slate-600">
        פלטפורמת מולטי־וונדור – לכל ספק קטלוג מקומי, מחירים מבוססי טיר ואפשרות לעדכון מלאי דרך קבצי JSON ניתנים לעריכה.
      </p>
      <div className="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {vendors.map((vendor) => (
          <div key={vendor.id} className="rounded-3xl bg-white p-6 text-center shadow-sm">
            <Image
              src={vendor.logo_url || '/placeholders/p0.png'}
              alt={vendor.name}
              width={80}
              height={80}
              className="mx-auto h-20 w-20 rounded-full object-cover"
            />
            <h2 className="mt-4 text-lg font-semibold text-slate-800">{vendor.name}</h2>
            <p className="mt-2 text-xs text-slate-500">slug: {vendor.slug}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
