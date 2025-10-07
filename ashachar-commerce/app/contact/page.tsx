export default function ContactPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-12">
      <h1 className="text-3xl font-bold text-slate-800">צור קשר</h1>
      <p className="mt-2 text-sm text-slate-600">
        נשמח לסייע במפרטים טכניים, הצעות מחיר מורכבות וסלי רכש לעסקים.
      </p>
      <div className="mt-6 space-y-4 rounded-3xl bg-white p-6 shadow-sm">
        <div>
          <h2 className="text-sm font-semibold text-slate-700">טלפון</h2>
          <a href="tel:089331441" className="text-sm text-emerald-600">
            ‎08-933-1441
          </a>
        </div>
        <div>
          <h2 className="text-sm font-semibold text-slate-700">מייל</h2>
          <a href="mailto:sales@ashachar.co.il" className="text-sm text-emerald-600">
            sales@ashachar.co.il
          </a>
        </div>
        <div>
          <h2 className="text-sm font-semibold text-slate-700">כתובת</h2>
          <p className="text-sm text-slate-600">הירקון 13, יבנה</p>
        </div>
      </div>
    </div>
  );
}
