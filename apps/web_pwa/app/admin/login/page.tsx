import Link from 'next/link';

function resolveRedirect(searchParams?: Record<string, string | string[] | undefined>): string {
  const rawValue = typeof searchParams?.redirect === 'string' ? searchParams.redirect : '/admin/catalog';
  if (!rawValue.startsWith('/admin')) {
    return '/admin/catalog';
  }
  return rawValue;
}

export default function AdminLoginPage({
  searchParams
}: {
  searchParams?: Record<string, string | string[] | undefined>;
}) {
  const redirectTarget = resolveRedirect(searchParams);
  const hasError = searchParams?.error === '1';

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-100 px-4 py-12">
      <div className="w-full max-w-md rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
        <h1 className="text-2xl font-semibold text-slate-800">כניסת מנהל</h1>
        <p className="mt-2 text-sm text-slate-600">
          הקלידו את ה-PIN שחולק באחסון הסודי כדי לנהל קטלוג מקומי.
        </p>
        {hasError ? (
          <p className="mt-4 rounded-2xl border border-rose-200 bg-rose-50 px-3 py-2 text-sm text-rose-700">
            PIN שגוי. נסו שוב.
          </p>
        ) : null}
        <form method="POST" action="/admin/login/submit" className="mt-6 space-y-4">
          <input type="hidden" name="redirect" value={redirectTarget} />
          <label className="flex flex-col gap-2 text-sm text-slate-600">
            PIN
            <input
              type="password"
              name="pin"
              required
              autoComplete="current-password"
              className="rounded-2xl border border-slate-200 px-3 py-2 text-lg tracking-[0.4em] text-slate-700 shadow-inner focus:border-emerald-500 focus:outline-none"
            />
          </label>
          <button
            type="submit"
            className="w-full rounded-full bg-emerald-500 px-4 py-2 text-center text-sm font-semibold text-white transition hover:bg-emerald-600"
          >
            כניסה לניהול
          </button>
        </form>
        <p className="mt-6 text-center text-xs text-slate-400">
          צריך עזרה? פנו למנהל המערכת כדי לעדכן את <code>.env.local</code>.
        </p>
        <p className="mt-2 text-center text-xs text-slate-400">
          <Link href="/" className="text-emerald-600 hover:underline">
            חזרה לאתר
          </Link>
        </p>
      </div>
    </div>
  );
}
