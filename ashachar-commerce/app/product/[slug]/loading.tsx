export default function LoadingProductPage() {
  return (
    <div className="mx-auto max-w-5xl px-4 py-12">
      <div className="h-4 w-32 animate-pulse rounded-full bg-slate-200" />
      <div className="mt-6 grid gap-10 md:grid-cols-2">
        <div className="rounded-3xl bg-white p-4 shadow-sm">
          <div className="aspect-square w-full animate-pulse rounded-2xl bg-slate-200" />
        </div>
        <div className="space-y-4">
          <div className="h-6 w-48 animate-pulse rounded-full bg-slate-200" />
          <div className="h-10 w-3/4 animate-pulse rounded-full bg-slate-200" />
          <div className="h-4 w-32 animate-pulse rounded-full bg-slate-200" />
          <div className="h-16 w-full animate-pulse rounded-2xl bg-slate-100" />
          <div className="h-10 w-40 animate-pulse rounded-full bg-emerald-200" />
          <div className="space-y-2">
            {Array.from({ length: 4 }).map((_, index) => (
              <div key={index} className="h-3 w-full animate-pulse rounded-full bg-slate-200" />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
