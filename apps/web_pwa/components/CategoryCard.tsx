import Image from 'next/image';
import Link from 'next/link';
import type { Category } from '@/lib/types';

export default function CategoryCard({ category }: { category: Category }) {
  return (
    <Link
      prefetch
      href={`/category/${category.slug}`}
      className="group overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
    >
      <div className="relative h-40 w-full">
        <Image
          src={category.image_url || '/placeholders/p0.png'}
          alt={category.name}
          fill
          className="object-cover transition-transform group-hover:scale-105"
          sizes="(max-width: 768px) 100vw, 33vw"
          loading="lazy"
        />
      </div>
      <div className="flex items-center justify-between px-4 py-3">
        <div>
          <div className="text-sm text-slate-500">קטגוריה</div>
          <div className="text-lg font-semibold text-slate-800">{category.name}</div>
        </div>
        <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700">
          לצפייה
        </span>
      </div>
    </Link>
  );
}
