import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50 px-4 py-12 text-center text-slate-700">
      <div className="max-w-md space-y-6">
        <p className="text-sm font-semibold text-emerald-600">404</p>
        <h1 className="text-3xl font-bold text-slate-900">הדף לא נמצא</h1>
        <p className="text-sm text-slate-600">
          לא הצלחנו למצוא את הדף שביקשתם. ייתכן שהוא הועבר או נמחק. חזרו לדף הבית או השתמשו בניווט העליון.
        </p>
        <Link
          prefetch
          href="/"
          className="inline-flex items-center justify-center rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-emerald-700"
        >
          חזרה לדף הבית
        </Link>
      </div>
    </div>
  );
}
