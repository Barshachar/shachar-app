import { CategoryCardSkeleton, ProductCardSkeleton } from '@/components/Skeletons';

export default function LoadingCategoryPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-12">
      <div className="mb-8 space-y-4 rounded-3xl bg-white p-6 shadow-sm">
        <div className="h-3 w-24 animate-pulse rounded-full bg-slate-200" />
        <div className="h-8 w-64 animate-pulse rounded-full bg-slate-200" />
        <div className="h-4 w-full max-w-xl animate-pulse rounded-full bg-slate-200" />
        <div className="flex flex-wrap gap-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <span
              key={index}
              className="h-8 w-24 animate-pulse rounded-full border border-slate-200 bg-slate-100"
            />
          ))}
        </div>
      </div>

      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {Array.from({ length: 8 }).map((_, index) => (
          <ProductCardSkeleton key={index} />
        ))}
      </div>

      <section className="mt-12">
        <div className="mb-4 h-6 w-48 animate-pulse rounded-full bg-slate-200" />
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <CategoryCardSkeleton key={index} />
          ))}
        </div>
      </section>
    </div>
  );
}
