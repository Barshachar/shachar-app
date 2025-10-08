export default function CheckoutFailedPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-20 text-center">
      <h1 className="text-3xl font-bold text-red-600">התשלום נכשל</h1>
      <p className="mt-4 text-sm text-slate-600">
        לא הצלחנו להשלים את התשלום דרך Cardcom. ניתן לנסות שוב או ליצור קשר עם שירות הלקוחות שלנו לקבלת סיוע.
      </p>
      <div className="mt-8 flex justify-center gap-4">
        <a
          href="/(store)/checkout"
          className="inline-flex rounded-full bg-emerald-600 px-5 py-3 text-sm font-semibold text-white hover:bg-emerald-700"
        >
          נסו שוב
        </a>
        <a href="tel:089331441" className="inline-flex rounded-full border border-slate-200 px-5 py-3 text-sm text-slate-600">
          צרו קשר טלפוני
        </a>
      </div>
    </div>
  );
}
