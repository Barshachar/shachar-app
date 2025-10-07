import Link from 'next/link';
import PricingModeToggle from '@/components/PricingModeToggle';
import VendorBadge from '@/components/VendorBadge';
import SearchBar from '@/components/SearchBar';

const PRIMARY_VENDOR = {
  name: 'א.שחר',
  logo_url: '/brands/ashachar.png'
};

export default function Header() {
  return (
    <header className="border-b border-slate-200 bg-white/95 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4">
        <div className="flex items-center gap-3">
          <Link prefetch href="/" className="flex items-center gap-2 text-emerald-700">
            <span className="inline-flex h-12 w-12 items-center justify-center rounded-full bg-emerald-600 text-lg font-semibold text-white shadow-lg">
              א
            </span>
            <div>
              <div className="text-lg font-semibold">א.שחר • אינסטלציה סיטונאית</div>
              <div className="text-sm text-slate-500">B2B/B2C מולטי־וונדור בישראל</div>
            </div>
          </Link>
          <VendorBadge vendor={PRIMARY_VENDOR} size="small" />
        </div>
        <nav className="flex items-center gap-6 text-sm">
          <Link prefetch href="/category/plumbing" className="hover:text-emerald-700">
            קטגוריות
          </Link>
          <Link prefetch href="/vendors" className="hover:text-emerald-700">
            ספקים
          </Link>
          <Link prefetch href="/contact" className="hover:text-emerald-700">
            צור קשר
          </Link>
          <Link prefetch href="/cart" className="font-semibold text-emerald-600">
            עגלה
          </Link>
        </nav>
        <SearchBar />
        <PricingModeToggle />
      </div>
    </header>
  );
}
