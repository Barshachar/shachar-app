import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="border-t border-slate-200 bg-white">
      <div className="mx-auto flex max-w-6xl flex-col gap-4 px-4 py-6 text-sm text-slate-600">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div>
            <div className="font-semibold text-slate-800">א.שחר • אינסטלציה סיטונאית</div>
            <div>הירקון 13, יבנה • ‎08-933-1441</div>
          </div>
          <div className="flex flex-wrap gap-4">
            <Link prefetch href="/terms" className="hover:text-emerald-600">
              תנאי שימוש
            </Link>
            <Link prefetch href="/privacy" className="hover:text-emerald-600">
              מדיניות פרטיות
            </Link>
            <Link prefetch href="/shipping" className="hover:text-emerald-600">
              משלוחים והחזרות
            </Link>
            <Link prefetch href="/accessibility" className="hover:text-emerald-600">
              הצהרת נגישות
            </Link>
          </div>
        </div>
        <div className="text-xs text-slate-400">
          © {new Date().getFullYear()} כל הזכויות שמורות. תומך RTL, מחירים ללקוחות פרטיים ולעסקים.
        </div>
      </div>
    </footer>
  );
}
