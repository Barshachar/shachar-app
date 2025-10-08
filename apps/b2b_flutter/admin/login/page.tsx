import { redirect } from 'next/navigation';

const ADMIN_COOKIE = 'admin_pin';

function getAdminPin(): string | null {
  const value = process.env.ADMIN_PIN;
  if (!value || !value.trim()) {
    return null;
  }
  return value.trim();
}

export const dynamic = 'force-dynamic';

export default function AdminLoginPage({ searchParams }: { searchParams?: { redirect?: string; error?: string } }) {
  const pin = getAdminPin();
  if (!pin) {
    redirect('/');
  }

  const error = searchParams?.error ? 'הקוד שהוזן שגוי. נסו שוב.' : '';

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
      <form
        action="/admin/login"
        method="post"
        className="flex flex-col gap-4 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm"
      >
        <h1 className="text-2xl font-bold text-slate-800">כניסה לממשק הניהול</h1>
        <p className="text-sm text-slate-600">הזינו את קוד ה-PIN כדי לגשת לאזור המוגן.</p>
        <input type="hidden" name="redirect" value={searchParams?.redirect || '/admin/catalog'} />
        <label className="flex flex-col gap-2 text-sm text-slate-700">
          קוד PIN
          <input
            type="password"
            name="pin"
            minLength={4}
            className="rounded-2xl border border-slate-300 px-3 py-2"
            autoFocus
            required
          />
        </label>
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        <button type="submit" className="rounded-full bg-emerald-600 px-4 py-2 text-sm font-semibold text-white">
          כניסה
        </button>
      </form>
    </div>
  );
}
