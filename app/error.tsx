'use client';

import Link from 'next/link';
import { useEffect } from 'react';

export default function GlobalError({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    console.error('Client error boundary triggered', error);
    const controller = new AbortController();
    const payload = {
      message: error?.message ?? 'Unknown error',
      digest: error?.digest ?? null,
      path: typeof window !== 'undefined' ? window.location.pathname : undefined
    };
    fetch('/api/log-error', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    }).catch((err) => {
      console.error('Failed to submit error log', err);
    });

    return () => controller.abort();
  }, [error]);

  return (
    <html lang="he" dir="rtl">
      <body className="flex min-h-screen flex-col items-center justify-center bg-slate-50 px-4 py-12 text-center text-slate-700">
        <div className="max-w-md space-y-6">
          <p className="text-sm font-semibold text-emerald-600">שגיאת מערכת</p>
          <h1 className="text-3xl font-bold text-slate-900">משהו השתבש</h1>
          <p className="text-sm text-slate-600">
            אנחנו עובדים על פתרון הבעיה. ניתן לנסות לרענן את הדף או לחזור לעמוד הבית.
          </p>
          <div className="flex items-center justify-center gap-3">
            <button
              type="button"
              onClick={() => reset()}
              className="rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-emerald-700"
            >
              נסו שוב
            </button>
            <Link
              prefetch
              href="/"
              className="rounded-full border border-slate-200 px-5 py-3 text-sm font-semibold text-slate-600 hover:border-emerald-400 hover:text-emerald-700"
            >
              חזרה לדף הבית
            </Link>
          </div>
        </div>
      </body>
    </html>
  );
}
