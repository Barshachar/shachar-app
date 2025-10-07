export function ProductCardSkeleton() {
  return (
    <div className="animate-pulse rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div className="h-48 w-full rounded-t-2xl bg-slate-200" />
      <div className="space-y-3 px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="h-3 w-20 rounded-full bg-slate-200" />
          <div className="h-3 w-12 rounded-full bg-slate-200" />
        </div>
        <div className="h-4 w-3/4 rounded-full bg-slate-200" />
        <div className="h-3 w-1/2 rounded-full bg-slate-200" />
        <div className="h-5 w-24 rounded-full bg-emerald-100" />
      </div>
    </div>
  );
}

export function CategoryCardSkeleton() {
  return (
    <div className="animate-pulse overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div className="h-40 w-full bg-slate-200" />
      <div className="space-y-2 px-4 py-3">
        <div className="h-3 w-16 rounded-full bg-slate-200" />
        <div className="h-4 w-32 rounded-full bg-slate-200" />
      </div>
    </div>
  );
}
